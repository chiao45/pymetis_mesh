import atexit
try:
    from mpi4py import MPI

    comm = MPI.COMM_WORLD
    exit_code = 0

    def _exit_code():
        if exit_code:
            import sys
            import traceback
            traceback.print_exc()
            sys.stderr.flush()
            comm.Abort()

    atexit.register(_exit_code)
    NO_MPI4PY = False
    COMM_SIZE = comm.size
except ImportError:
    NO_MPI4PY = True
    COMM_SIZE = 1
