from psycopg2.extensions import ISOLATION_LEVEL_REPEATABLE_READ
from psycopg2.errors import SerializationFailure, InFailedSqlTransaction
from decimal import Decimal
from topup import TopupTask
from runner import run_in_parallel
from reset_db import reset_db_state
from balances import print_current_balances
from timeit import timeit


def topup_v5(conn, task: TopupTask):
    # could also be ISOLATION_LEVEL_SERIALIZABLE
    conn.set_isolation_level(ISOLATION_LEVEL_REPEATABLE_READ)
    while True:
        try:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    SELECT wallet_id, balance 
                    FROM wallet 
                        RIGHT JOIN account ON wallet.account_id = account.account_id
                    WHERE account.name = %s
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

            break
        except SerializationFailure:
            pass  # retrying
        except InFailedSqlTransaction:
            conn.rollback()  # retrying

    conn.commit()


@timeit
def main():
    reset_db_state()
    print("Initial balances:")
    print_current_balances()
    tasks = [TopupTask("Account A", Decimal("1.0")) for i in range(0, 1000)]
    run_in_parallel(topup_v5, tasks, concurrency=20)
    print("Updated balances:")
    print_current_balances()


if __name__ == "__main__":
    main()
