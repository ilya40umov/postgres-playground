from decimal import Decimal
from topup import TopupTask
from runner import run_in_parallel
from reset_db import reset_db_state
from balances import print_current_balances
from timeit import timeit


def topup_v2(conn, task: TopupTask):
    with conn.cursor() as cur:
        # using atomic operation
        cur.execute(
            """
            UPDATE wallet 
            SET balance = balance + %s, updated = NOW() 
            FROM (
                SELECT wallet_id 
                FROM wallet 
                    RIGHT JOIN account 
                        ON wallet.account_id = account.account_id
                WHERE account.name = %s
            ) as w
            WHERE wallet.wallet_id = w.wallet_id
            RETURNING wallet.wallet_id, wallet.balance
        """,
            (
                task.amount,
                task.account_name,
            ),
        )

        # we can even get the new state of wallet back from this query
        row = cur.fetchone()
        wallet_id = row[0]
        balance = row[1]
    conn.commit()


@timeit
def main():
    reset_db_state()
    print("Initial balances:")
    print_current_balances()
    tasks = [TopupTask("Account A", Decimal("1.0")) for i in range(0, 1000)]
    run_in_parallel(topup_v2, tasks, concurrency=20)
    print()
    print("Updated balances:")
    print_current_balances()


if __name__ == "__main__":
    main()
