import threading
import queue
from collections.abc import Callable
from psycopg2._psycopg import connection
from conn import get_connection


def run_in_parallel[T](
    func: Callable[[connection, T], None], tasks: list[T], concurrency: int
):
    backlog = queue.Queue()

    for task in tasks:
        backlog.put(task)

    for i in range(0, concurrency):
        backlog.put(None)

    def _runner():
        conn = get_connection()
        while True:
            task = backlog.get()
            if task is None:
                break
            func(conn, task)
        conn.close()

    threads = []
    for i in range(0, concurrency):
        t = threading.Thread(name=f"thread{i}", target=_runner)
        t.start()
        threads.append(t)

    for t in threads:
        t.join()
