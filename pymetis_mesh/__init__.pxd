# METIS Cython interface for mesh partitioning

cimport libc.stdint as stdint


cdef extern from 'metis.h' nogil:
    ctypedef stdint.int32_t idx_t
    ctypedef float real_t

    int nmbr 'METIS_OPTION_NUMBERING'
    int dbglvl 'METIS_OPTION_DBGLVL'
    int err_in 'METIS_ERROR_INPUT'
    int err_mem 'METIS_ERROR_MEMORY'
    int err 'METIS_ERROR'

    # APIs
    int METIS_PartMeshDual(
        idx_t *ne,
        idx_t *nn,
        idx_t *eptr,
        idx_t *eind,
        idx_t *vwgt,
        idx_t *vsize,
        idx_t *ncommon,
        idx_t *nparts,
        real_t *tpwgts,
        idx_t *options,
        idx_t *objval,
        idx_t *epart,
        idx_t *npart
    )
    int METIS_PartMeshNodal(
        idx_t *ne,
        idx_t *nn,
        idx_t *eptr,
        idx_t *eind,
        idx_t *vwgt,
        idx_t *vsize,
        idx_t *nparts,
        real_t *tpwgts,
        idx_t *options,
        idx_t *objval,
        idx_t *epart,
        idx_t *npart
    )
    int METIS_SetDefaultOptions(idx_t *options)

    # options
    int _ptype 'METIS_OPTION_PTYPE'
    int _objtype 'METIS_OPTION_OBJTYPE'
    int _ctype 'METIS_OPTION_CTYPE'
    int _rtype 'METIS_OPTION_RTYPE'
    int _niter 'METIS_OPTION_NITER'
    int _ufactor 'METIS_OPTION_UFACTOR'

    # option values

    int ptype_rb 'METIS_PTYPE_RB'
    int ptype_kway 'METIS_PTYPE_KWAY'

    int objtype_cut 'METIS_OBJTYPE_CUT'
    int objtype_vol 'METIS_OBJTYPE_VOL'
    int objtype_node 'METIS_OBJTYPE_NODE'

    int ctype_rm 'METIS_CTYPE_RM'
    int ctype_shem 'METIS_CTYPE_SHEM'

    int rtype_fm 'METIS_RTYPE_FM'
    int rtype_greedy 'METIS_RTYPE_GREEDY'
    int rtype_sep2sided 'METIS_RTYPE_SEP2SIDED'
    int rtype_sep1sided 'METIS_RTYPE_SEP1SIDED'
