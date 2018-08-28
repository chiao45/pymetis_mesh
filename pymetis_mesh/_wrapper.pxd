"""Header of Options"""

cimport pymetis_mesh as libmetis

DEF NOPTIONS = 40

cdef class Options:
    cdef libmetis.idx_t opts[NOPTIONS]
