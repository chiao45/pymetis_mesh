#!python
#cython: boundscheck=False, embedsignature=True, wraparound=False

cimport pymetis_mesh.parmetis as parmetis
cimport numpy as np
cimport mpi4py.libmpi as cmpi
cimport mpi4py.MPI as MPI

ctypedef parmetis.idx_t idx_t
ctypedef parmetis.real_t real_t
ctypedef MPI.Comm comm_t
ctypedef cmpi.MPI_Comm c_comm_t

import numpy as np
from ._version import __version__
from .errors import *


__version__ = __version__
__author__ = 'Qiao Chen'
__copyright__ = 'Copyright 2018, Qiao Chen'
