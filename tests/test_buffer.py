# add pymetis_mesh if inplace
import sys
sys.path.append('../')
from pymetis_mesh import *
import numpy as np
from load_mesh import load_mesh


def test_buffere():
    nv, ne, eptr, eind = load_mesh()
    epart = np.empty(ne, dtype='int32')
    outputs = part_mesh(nv, eptr, eind, 4, ncommon=3, epart=epart)
    assert sum([np.where(epart == x)[0].size for x in range(4)]) == ne


def test_buffern():
    nv, ne, eptr, eind = load_mesh()
    npart = np.empty(nv, dtype='int32')
    outputs = part_mesh(nv, eptr, eind, 4, ncommon=3,
                        npart=npart, elemental=False)
    assert sum([np.where(npart == x)[0].size for x in range(4)]) == nv
