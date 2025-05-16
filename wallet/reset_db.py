from conn import get_connection


def reset_db_state():
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute("TRUNCATE TABLE account, wallet")
        cur.execute(
            """
            INSERT INTO account (name)
            VALUES ('Account A'), ('Account B'), ('Account C')
        """
        )
        cur.execute(
            """
            WITH initial_data AS (
              SELECT
                account_id,
                '1000.0'::numeric as balance
              FROM account
            )
            INSERT INTO wallet (account_id, balance) 
            SELECT * FROM initial_data
        """
        )

    conn.commit()
    conn.close()
