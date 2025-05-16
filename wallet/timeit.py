import time


def timeit(method):
    def timed(*args, **kwargs):
        start_time = time.time()
        result = method(*args, **kwargs)
        elapsed = time.time() - start_time
        print(f"Time taken: {elapsed:0.3f}s")
        return result

    return timed
