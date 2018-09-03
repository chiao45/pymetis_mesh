#!python
#cython: boundscheck=False, embedsignature=True, wraparound=False

"""ParMETIS wrapper for partitioning `finite element` meshes

This module wraps routines for partitioning/repartioning FE unstructured meshes
in parallel environments.
"""

from libc.stdlib cimport malloc, free
cimport pymetis_mesh.parmetis as parmetis
cimport numpy as np
cimport mpi4py.libmpi as cmpi
cimport mpi4py.MPI as MPI

ctypedef parmetis.idx_t idx_t
ctypedef parmetis.real_t real_t
ctypedef MPI.Comm comm_t
ctypedef cmpi.MPI_Comm c_comm_t

cdef extern from 'mpi-compat.h':
    pass

import numpy as np
from ._version import __version__
from .errors import *
from ._wrapper cimport *


__version__ = __version__
__author__ = 'Qiao Chen'
__copyright__ = 'Copyright 2018, Qiao Chen'


__all__ = [
    'parpart_mesh',
]


cdef inline int _run_par(c_comm_t comm) nogil:
    cdef int flag = 0
    cdef int size = 1
    cmpi.MPI_Initialized(&flag)
    if flag:
        cmpi.MPI_Comm_size(comm, &size)
    return flag and (size > 1)


cdef inline int _par_size(c_comm_t comm) nogil:
    cdef int size
    cmpi.MPI_Comm_size(comm, &size)
    return size


cdef inline int _par_rank(c_comm_t comm) nogil:
    cdef int rank
    cmpi.MPI_Comm_rank(comm, &rank)
    return rank


def parpart_mesh(
    idx_t[::1] eptr not None,
    idx_t[::1] eind not None,
    *,
    int nparts=-1,
    comm_t comm=None,
    real_t[::1] tpwgts=None,
    int ncommon=2,
    one_base=False,
    debug=0,
    idx_t[::1] epart=None):
    """The main interface

    Parameters
    ----------
    eptr : memory view
        distributed CRS element index pointer array
    eind : memory view
        distributed CRS element connectivity array, IDs are global
    nparts : int (optional)
        number of partitions, default is communicator size
    comm : MPI.Comm (optional)
        default communicator is ``MPI_COMM_WORLD``
    tpwgts : memory view (optional)
        partition weights, default is [1/nparts ...]
    ncommon : int (optional)
        number of shared nodes that forms a cut, default is 2
    one_base : bool (optional)
        ``True`` if using Fortran-based index, default is ``False``
    debug : int (optional)
        debugging flags, default is 0, i.e. no debug
    epart : memory view (optional)
        buffer, if specified, must be the size of local elements

    Returns
    -------
    dict with keys ``cuts`` and ``epart``
    """
    cdef:
        c_comm_t _comm = cmpi.MPI_COMM_WORLD if comm is None else comm.ob_mpi
        idx_t _nparts = <idx_t> nparts
        idx_t numflag = 1 if one_base else 0
        idx_t wgtflag = 0  # for now
        idx_t ncon = 1  # for now
        real_t ubvec = 1.05
        idx_t opts[10]
        real_t *_tpwgts = &tpwgts[0] if tpwgts is not None else NULL
        int can_free = 0
        np.ndarray[np.int32_t, ndim=1] elmdist
        int size
        int rank
        idx_t _ncommon = ncommon
        int ret
        int i
        int ne = len(eptr) - 1
        Options _foo

        # outputs
        np.ndarray[np.int32_t, ndim=1] _epart
        idx_t edgecut

    if not _run_par(_comm):
        raise MetisError('use part_mesh for serial runs')
    # safe to query comm size and rank
    size = _par_size(_comm)
    rank = _par_rank(_comm)
    if _nparts <= 0:
        _nparts = size
    if _nparts <= 0:
        raise MetisInputError('nparts')
    if not (_tpwgts == NULL or len(tpwgts) == _nparts):
        raise MetisInputError('tpwgts')
    if ne < 0:
        raise MetisInputError('eptr')
    if debug < 0:
        raise MetisInputError('debug')
    if _tpwgts is NULL:
        can_free = 1
        _tpwgts = <real_t *> malloc(_nparts * sizeof(real_t))
        if _tpwgts is NULL:
            raise MetisMemoryError('bad alloc')
        for i in range(_nparts):
            _tpwgts[i] = 1./_nparts
    opts[0] = 1 if debug else 0
    opts[1] = <idx_t> debug
    elmdist = np.empty(size+1, dtype=np.int32)
    elmdist[0] = 0
    elmdist[rank+1] = ne
    ret = cmpi.MPI_Allgather(
        &elmdist[rank+1],
        1,
        parmetis.mpi_idx_t,
        &elmdist[1],
        1,
        parmetis.mpi_idx_t,
        _comm
    )
    if ret:
        raise MetisError('MPI_Allgather failed')
    for i in range(size):
        elmdist[i+1] += elmdist[i]
    if epart is None:
        _epart = np.empty(ne, dtype=np.int32)
    else:
        if len(epart) != ne:
            raise MetisInputError('epart')
        _epart = np.asarray(epart)

    # call interface
    ret = parmetis.ParMETIS_V3_PartMeshKway(
        <idx_t *> elmdist.data,
        <idx_t *> &eptr[0],
        <idx_t *> &eind[0],
        NULL,
        &wgtflag,
        &numflag,
        &ncon,
        &_ncommon,
        &_nparts,
        _tpwgts,
        &ubvec,
        opts,
        &edgecut,
        <idx_t *> _epart.data,
        &_comm
    )
    if can_free:
        free(_tpwgts)
    if ret == 1:
        return {'cuts': edgecut, 'epart': _epart}
    else:
        raise MetisError('routine didn\'t return METIS_OK')
