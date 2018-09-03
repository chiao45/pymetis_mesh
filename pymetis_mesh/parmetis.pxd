"""ParMETIS Header"""

cimport pymetis_mesh as libmetis
cimport mpi4py.libmpi as cmpi


cdef extern from 'src/include/parmetis.h' nogil:
    ctypedef libmetis.idx_t idx_t
    ctypedef libmetis.real_t real_t

    cmpi.MPI_Datatype mpi_idx_t 'IDX_T'
    cmpi.MPI_Datatype mpi_real_t 'REAL_T'

    int ParMETIS_V3_Mesh2Dual(
        idx_t *elmdist,
        idx_t *eptr,
        idx_t *eind,
        idx_t *numflag,
    	idx_t *ncommonnodes,
        idx_t **xadj,
        idx_t **adjncy,
        cmpi.MPI_Comm *comm
    )
    int ParMETIS_V3_PartMeshKway(
        idx_t *elmdist,
        idx_t *eptr,
        idx_t *eind,
        idx_t *elmwgt,
    	idx_t *wgtflag,
        idx_t *numflag,
        idx_t *ncon,
        idx_t *ncommonnodes,
        idx_t *nparts,
    	real_t *tpwgts,
        real_t *ubvec,
        idx_t *options,
        idx_t *edgecut,
        idx_t *part,
    	cmpi.MPI_Comm *comm
    )
