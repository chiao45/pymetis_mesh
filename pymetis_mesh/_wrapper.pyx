#!python
#cython: boundscheck=False, embedsignature=True, wraparound=False

"""METIS wrapper for partitioning `finite element` (FE) meshes

This module is designed to wrap around the two METIS routines for partitioning
FE meshes either in node-wise or element-wise setting. This routine is designed
to map to the original APIs with numpy ndarrays as input/output arguments.

Attributes
----------
PTYPE_RB: int
    Multilevel recursive bisectioning partitioning method
PTYPE_KWAY: int
    Multilevel k-way partitioning method
OBJTYPE_CUT: int
    Edge-cut minimization
OBJTYPE_VOL: int
    Total communication volume minimization
CTYPE_RM: int
    Random matching during coarsening
CTYPE_SHEM: int
    Sorted heavy-edge matching during coarsening
RTYPE_FM: int
    FM-based cut refinement
RTYPE_GREEDY: int
    Greedy-based cut and volume refinement
RTYPE_SEP2SIDED: int
    Two-sided node FM refinement
RTYPE_SEP1SIDED: int
    One-sided node FM refinement
"""

cimport numpy as np
cimport pymetis_mesh as libmetis

import numpy as np
from ._version import __version__
from .errors import *


DEF NOPTIONS = 40

__version__ = __version__
__author__ = 'Qiao Chen'
__copyright__ = 'Copyright 2018, Qiao Chen'

__all__ = [
    'PTYPE_RB',
    'PTYPE_KWAY',
    'OBJTYPE_CUT',
    'OBJTYPE_VOL',
    'OBJTYPE_NODE',
    'CTYPE_RM',
    'CTYPE_SHEM',
    'RTYPE_FM',
    'RTYPE_GREEDY',
    'RTYPE_SEP2SIDED',
    'RTYPE_SEP1SIDED',
    'DEFAULT',
    'Options',
    'part_mesh',
]

# simply define all option values as module attributes

PTYPE_RB = libmetis.ptype_rb
PTYPE_KWAY = libmetis.ptype_kway

OBJTYPE_CUT = libmetis.objtype_cut
OBJTYPE_VOL = libmetis.objtype_vol
OBJTYPE_NODE = libmetis.objtype_node

CTYPE_RM = libmetis.ctype_rm
CTYPE_SHEM = libmetis.ctype_shem

RTYPE_FM = libmetis.rtype_fm
RTYPE_GREEDY = libmetis.rtype_greedy
RTYPE_SEP2SIDED = libmetis.rtype_sep2sided
RTYPE_SEP1SIDED = libmetis.rtype_sep1sided

DEFAULT = -1

_PTYPE_STR = {
    PTYPE_RB : 'PTYPE_RB',
    PTYPE_KWAY : 'PTYPE_KWAY',
    DEFAULT : 'DEFAULT',
}
_OBJTYPE_STR = {
    OBJTYPE_CUT : 'OBJTYPE_CUT',
    OBJTYPE_VOL : 'OBJTYPE_VOL',
    OBJTYPE_NODE : 'OBJTYPE_NODE',
    DEFAULT : 'DEFAULT',
}
_CTYPE_STR = {
    CTYPE_RM : 'CTYPE_RM',
    CTYPE_SHEM : 'CTYPE_SHEM',
    DEFAULT : 'DEFAULT',
}
_RTYPE_STR = {
    RTYPE_FM : 'RTYPE_FM',
    RTYPE_GREEDY : 'RTYPE_GREEDY',
    RTYPE_SEP2SIDED : 'RTYPE_SEP2SIDED',
    RTYPE_SEP1SIDED : 'RTYPE_SEP1SIDED',
    DEFAULT : 'DEFAULT',
}
_ATTR2STRS = {
    'ptype': lambda x: _PTYPE_STR[x],
    'objtype': lambda x: _OBJTYPE_STR[x],
    'ctype': lambda x: _CTYPE_STR[x],
    'rtype': lambda x: _RTYPE_STR[x],
    'niter': lambda x: '10' if x == -1 else '{}'.format(x),
    'ufactor': lambda x: '30' if x == -1 else '{}'.format(x),
}


cdef class Options:
    """Option switches for METIS mesh partitioning

    Attributes
    ----------
    ptype: int
        Partition schemes
    objtype: int
        minimization requirements
    ctype: int
        coarsening schemes
    rtype: int
        refinement schemes
    niter: int
        number of refinement iterations
    ufactor: int
        local imbalance parameter

    Examples
    --------
    >>> from pymetis_mesh import *
    >>> opts = Options()
    >>> opts.ptype = PTYPE_RB
    """

    def __init__(self):
        pass

    def __cinit__(self):
        libmetis.METIS_SetDefaultOptions(self.opts)

    def __dealloc__(self):
        pass

    @property
    def ptype(self):
        """Partition method

        Define the partition methods used, possible values are:
        :attr:`PTYPE_RB`, :attr:`PTYPE_KWAY`
        """
        return self.opts[libmetis._ptype]

    @ptype.setter
    def ptype(self, int p):
        if p != PTYPE_RB and p != PTYPE_KWAY:
            raise MetisInputError('unknown ptype %r' % p)
        self.opts[libmetis._ptype] = <int> p

    @property
    def objtype(self):
        """minimization requirements

        possible values are: :attr:`OBJTYPE_CUT`, :attr:`OBJTYPE_VOL`,
        and :attr:`OBJTYPE_NODE`.
        """
        return self.opts[libmetis._objtype]

    @objtype.setter
    def objtype(self, int obj):
        if obj != OBJTYPE_CUT and obj != OBJTYPE_VOL and obj != OBJTYPE_NODE:
            raise MetisInputError('unknown objtype %r' % obj)
        self.opts[libmetis._objtype] = <int> obj

    @property
    def ctype(self):
        """Get the coarsening scheme

        possible values are: :attr:`CTYPE_RM` and :attr:`CTYPE_SHEM`
        """
        return self.opts[libmetis._ctype]

    @ctype.setter
    def ctype(self, int c):
        if c != CTYPE_RM and c != CTYPE_SHEM:
            raise MetisInputError('unknown ctype %r' % c)
        self.opts[libmetis._ctype] = <int> c

    @property
    def rtype(self):
        """Get the refinement scheme

        Possible values are: :attr:`RTYPE_FM`, :attr:`RTYPE_GREEDY`,
        :attr:`RTYPE_SEP2SIDED`. and :attr:`RTYPE_SEP1SIDED`
        """
        return self.opts[libmetis._rtype]

    @rtype.setter
    def rtype(self, int r):
        if r != RTYPE_FM and r != RTYPE_GREEDY and r != RTYPE_SEP2SIDED \
            and r != RTYPE_SEP1SIDED:
            raise MetisInputError('unknown rtype %r' % r)
        self.opts[libmetis._rtype] = <int> r

    @property
    def niter(self):
        """int: Get the number of iterations used in refinement step

        .. note:: The default value is 10
        """
        cdef int n = self.opts[libmetis._niter]
        return 10 if n == DEFAULT else n

    @niter.setter
    def niter(self, int its):
        if its <= 0:
            raise MetisInputError('Invalid interation number %i' % its)
        self.opts[libmetis._niter] = <int> its

    @property
    def ufactor(self):
        """int: Get the maximum allowed load imbalance among the partitions"""
        cdef int n = self.opts[libmetis._ufactor]
        return 30 if n == DEFAULT else n

    @ufactor.setter
    def ufactor(self, int u):
        self.opts[libmetis._ufactor] = <int> u

    def __str__(self):
        str = ''
        for attr in Options.__dict__:
            try:
                str += attr + ':' + _ATTR2STRS[attr](getattr(self, attr)) + '\n'
            except Exception:
                pass
        return str

    def __repr__(self):
        return self.__str__()


# helper function
cdef inline void _copy_opts(libmetis.idx_t *opts_out, Options opts_in) nogil:
    cdef int i
    for i in range(NOPTIONS):
        opts_out[i] = opts_in.opts[i]


def part_mesh(
    int nv,
    libmetis.idx_t[::1] eptr not None,
    libmetis.idx_t[::1] eind not None,
    int nparts, *,
    int ncommon=1,
    libmetis.idx_t[::1] vwgt=None,
    libmetis.idx_t[::1] vsize=None,
    libmetis.real_t[::1] tpwgts=None,
    one_base=False,
    elemental=True,
    debug=0,
    Options opts=None,
    libmetis.idx_t[::1] epart=None,
    libmetis.idx_t[::1] npart=None):
    """The main partition interface

    Parameters
    ----------
    nv : int
        number of nodes
    eptr : memory view
        element pointer array, size of ne-1, where ne is the number of elements
    eind : memory view
        flattened connectivity table
    nparts : int
        number of partitions
    ncommon : int (optional)
        number of shared nodes that forms a cut, elemental part only
    vwgt : memory view (optional)
        weights of primary entity type
    vsize : memory view (optional)
        communication volumes of primary entity type
    tpwgts : memory view (optional)
        weights for partitions
    one_base : bool (optional)
        ``True`` if using Fortran-based index
    elemental : bool (optional)
        ``True`` if doing element-based partition
    debug: int (optional)
        debug level
    opts: :class:`Options`
        additional switch control parameters
    epart : memory view (optional)
        buffer output of element partition
    npart : memory view (optional)
        buffer output of node partition

    Returns
    -------
    dict with keys ``cuts``, ``epart``, ``npart``
        cuts, epart, npart

    Examples
    --------
    >>> from pymetis_mesh import *
    >>> import numpy as np
    >>> eptr = np.asarray([0, 3, 6], dtype='int32')
    >>> # two triangles, 4 nodes
    >>> eind = np.asarray([0, 1, 2, 0, 2, 3], dtype='int32')
    >>> outputs = part_mesh(4, eptr, eind, 2) # elemental wise two-part
    """
    cdef:
        # inputs
        libmetis.idx_t _nparts = nparts
        libmetis.idx_t _ncommon = ncommon
        libmetis.idx_t _ne = len(eptr) - 1
        libmetis.idx_t _nv = nv
        libmetis.idx_t *_vwgt = &vwgt[0] if vwgt is not None else NULL
        libmetis.idx_t *_vsize = &vsize[0] if vsize is not None else NULL
        libmetis.real_t *_tpwgts = &tpwgts[0] if tpwgts is not None else NULL
        int ret
        int dbg = <int> debug
        libmetis.idx_t _opts[NOPTIONS]
        # outputs
        libmetis.idx_t objval
        np.ndarray[np.int32_t, ndim=1] _epart
        np.ndarray[np.int32_t, ndim=1] _npart
    if _nparts <= 0:
        raise MetisInputError('nparts')
    if not (_vwgt == NULL or (len(vwgt) == _ne and elemental) or len(vwgt) == _nv):
        raise MetisInputError('vwgt')
    if not (_vsize == NULL or (len(vsize) == _ne and elemental) or len(vwgt) == _nv):
        raise MetisInputError('vsize')
    if not (_tpwgts == NULL or len(tpwgts) == _nparts):
        raise MetisInputError('tpwgts')
    if dbg < 0:
        raise MetisInputError('debug')
    if epart is None:
        _epart = np.empty(_ne, dtype=np.int32)
    else:
        if len(epart) != _ne:
            raise MetisInputError('epart')
        _epart = np.asarray(epart)
    if npart is None:
        _npart = np.empty(_nv, dtype=np.int32)
    else:
        if len(npart) != _nv:
            raise MetisInputError('npart')
        _npart = np.asarray(npart)
    if opts is None:
        libmetis.METIS_SetDefaultOptions(_opts)
    else:
        if not isinstance(opts, Options):
            raise MetisInputError('opts')
        _copy_opts(_opts, opts)
    _opts[libmetis.nmbr] = 1 if one_base else 0
    if dbg:
        _opts[libmetis.dbglvl] = dbg
    if elemental:
        ret = libmetis.METIS_PartMeshDual(
            &_ne,
            &_nv,
            <libmetis.idx_t *> &eptr[0],
            <libmetis.idx_t *> &eind[0],
            _vwgt,
            _vsize,
            &_ncommon,
            &_nparts,
            _tpwgts,
            _opts,
            &objval,
            <libmetis.idx_t *> _epart.data,
            <libmetis.idx_t *> _npart.data
        )
    else:
        ret = libmetis.METIS_PartMeshNodal(
            &_ne,
            &_nv,
            <libmetis.idx_t *> &eptr[0],
            <libmetis.idx_t *> &eind[0],
            _vwgt,
            _vsize,
            &_nparts,
            _tpwgts,
            _opts,
            &objval,
            <libmetis.idx_t *> _epart.data,
            <libmetis.idx_t *> _npart.data
        )
    if ret == 1:
        return {'cuts': objval, 'epart': _epart, 'npart': _npart}
    elif ret == err_in:
        raise MetisInputError('invalid input arguments')
    elif ret == err_mem:
        raise MetisMemoryError('bad alloc')
    else:
        raise MetisError('routine didn\'t return METIS_OK')
