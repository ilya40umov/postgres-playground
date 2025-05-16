from conn import get_connection


def print_current_balances():
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT account.name, wallet.balance 
            FROM account 
                LEFT JOIN wallet ON account.account_id = wallet.account_id
            ORDER BY account.account_id ASC
        """
        )
        account_infos = cur.fetchall()
        print()
        for account_info in account_infos:
            print(f"{account_info[0]:<20} {account_info[1]:>10}")
        print()
    conn.close()
