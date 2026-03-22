import re


ANSI_ESCAPE_RE = re.compile(r"\x1B\[[0-?]*[ -/]*[@-~]")


class TeeStream:
    def __init__(self, terminal_stream, log_handle):
        self.terminal_stream = terminal_stream
        self.log_handle = log_handle

    def write(self, data):
        if not data:
            return 0

        self.terminal_stream.write(data)
        self.log_handle.write(ANSI_ESCAPE_RE.sub("", data))
        return len(data)

    def flush(self):
        self.terminal_stream.flush()
        self.log_handle.flush()

    def isatty(self):
        return self.terminal_stream.isatty()
