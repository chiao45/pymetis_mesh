import pymetis_mesh.errors as errors
from ._version import __version__
from ._wrapper import *


DBG_NULL = 0
DBG_INFO = 1
DBG_TIME = 2
DBG_COARSEN = 4
DBG_REFINE = 8
DBG_IPART = 16
DBG_MOVEINFO = 32
DBG_SEPINFO = 64
DBG_CONNINFO = 128
DBG_CONTIGINFO = 256
DBG_MEMORY = 2048


def get_include():
    import os
    return os.path.abspath(os.path.dirname(os.path.abspath(__file__)))
