from decimal import Decimal
import psycopg2
import psycopg2.extras
import os
from dotenv import load_dotenv
import faker
import random


def insert_in_bulk(conn, records, query):
    with conn.cursor() as cur:
        psycopg2.extras.execute_values(
            cur, query, records, template=None, page_size=100
        )
    conn.commit()


def main():
    print("Initializing...")

    load_dotenv()

    fake = faker.Faker()
    fake.add_provider(faker.providers.company)
    fake.add_provider(faker.providers.geo)
    fake.add_provider(faker.providers.date_time)
    fake.add_provider(faker.providers.person)
    fake.add_provider(faker.providers.lorem)

    conn = psycopg2.connect(
        database="feedback",
        host="localhost",
        port=5432,
        user=os.environ["POSTGRES_USER"],
        password=os.environ["POSTGRES_PASSWORD"],
    )

    print("Generating businesses...")
    businesses = []
    for i in range(0, 5000):
        loc = fake.local_latlng(country_code="US", coords_only=True)
        businesses.append(
            {
                "name": fake.company(),
                "description": fake.catch_phrase(),
                "lat": loc[0],
                "lon": loc[1],
                "active": i % 3 != 0,
                "registered": fake.date_time_this_decade(),
            }
        )
    print("Inserting businesses...")
    insert_in_bulk(
        conn,
        [tuple(business.values()) for business in businesses],
        "INSERT INTO business (name, description, lat, lon, active, registered) values %s",
    )
    print("Done")

    print("Generating customers...")
    customers = []
    for i in range(0, 10000):
        customers.append(
            {
                "name": f"{fake.prefix()} {fake.name()} {random.randint(1, 1000)}",
                "banned_from": [
                    random.randint(1, len(businesses)), 
                    random.randint(1, len(businesses)),
                    random.randint(1, len(businesses))
                ],
                "registered": fake.date_time_this_decade(),
            }
        )
    print("Inserting customers...")
    insert_in_bulk(
        conn,
        [tuple(customer.values()) for customer in customers],
        "INSERT INTO customer (name, banned_from, registered) values %s",
    )
    print("Done")

    print("Generating feedback...")
    feedbacks = []
    for business_id in range(1, len(businesses) + 1):
        for i in range(0, random.randint(1, 11)):
            customer_id = random.randint(1, len(customers))
            feedbacks.append(
                {
                    "business_id": business_id,
                    "customer_id": customer_id,
                    "message": fake.paragraph(nb_sentences=5),
                    "last_edited": fake.date_time_this_decade(
                        businesses[business_id - 1]["registered"],
                        customers[customer_id - 1]["registered"]
                    ),
                }
            )
    sorted(feedbacks, key=lambda f: f["last_edited"])
    print("Inserting feedback...")
    insert_in_bulk(
        conn,
        [tuple(feedback.values()) for feedback in feedbacks],
        "INSERT INTO feedback (business_id, customer_id, message, last_edited) values %s",
    )
    print("Done")

    print("Running ANALYZE")
    with conn.cursor() as cur:
        cur.execute("ANALYZE business")
        cur.execute("ANALYZE customer")
        cur.execute("ANALYZE feedback")
    print("Done")

    conn.close()


if __name__ == "__main__":
    main()
