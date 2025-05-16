from decimal import Decimal
from topup import TopupTask
from runner import run_in_parallel
from reset_db import reset_db_state
from balances import print_current_balances
from timeit import timeit


def topup_v3(conn, task: TopupTask):
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT wallet_id, balance 
            FROM wallet 
                INNER JOIN account ON wallet.account_id = account.account_id
            WHERE account.name = %s
            FOR UPDATE OF wallet
        """,
            (task.account_name,),
        )

        row = cur.fetchone()
        wallet_id = row[0]
        balance = row[1]

        balance += task.amount

        cur.execute(
            "UPDATE wallet SET balance = %s, updated = NOW() WHERE wallet_id = %s",
            (
                balance,
                wallet_id,
            ),
        )
    conn.commit()


@timeit
def main():
    reset_db_state()
    print("Initial balances:")
    print_current_balances()
    tasks = [TopupTask("Account A", Decimal("1.0")) for i in range(0, 1000)]
    run_in_parallel(topup_v3, tasks, concurrency=20)
    print("Updated balances:")
    print_current_balances()


if __name__ == "__main__":
    main()
