import os
import sys
from contextlib import contextmanager

from tee_stream import TeeStream


@contextmanager
def use_log_file(log_file):
    if not log_file:
        yield
        return

    log_dir = os.path.dirname(log_file)
    if log_dir:
        os.makedirs(log_dir, exist_ok=True)

    with open(log_file, mode="w", encoding="utf-8", newline="") as log_handle:
        original_stdout = sys.stdout
        original_stderr = sys.stderr
        sys.stdout = TeeStream(original_stdout, log_handle)
        sys.stderr = TeeStream(original_stderr, log_handle)
        try:
            yield
        finally:
            sys.stdout.flush()
            sys.stderr.flush()
            sys.stdout = original_stdout
            sys.stderr = original_stderr
