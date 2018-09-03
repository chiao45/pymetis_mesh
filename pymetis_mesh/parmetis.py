"""ParMETIS module"""

_ERROR_MSG = """
ParMETIS interface is not available, you need first install mpi4py, then
reinstall pymetis_mesh. This will allow pymetis_mesh safely assumes that MPI
is available, so that building ParMETIS is feasible.
"""

try:
    from ._parwrapper import *
except ImportError:
    import sys
    sys.stderr.write(_ERROR_MSG)
    sys.stderr.flush()
    raise


PARDBG_TIME = 1
PARDBG_INFO = 2
PARDBG_PROGRESS = 4
PARDBG_REFINEINFO = 8
PARDBG_MATCHINFO = 16
PARDBG_REMOVEINFO = 32
PARDBG_REMAP = 64
