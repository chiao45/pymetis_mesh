# add pymetis_mesh if inplace
import sys
sys.path.append('../')
from pymetis_mesh import *
import numpy as np
from load_mesh import load_mesh


def test_options1():
    nv, ne, eptr, eind = load_mesh()
    opts = Options()
    opts.ptype = PTYPE_RB
    opts.ctype = CTYPE_SHEM
    outputs = part_mesh(nv, eptr, eind, 4, ncommon=3,
                        debug=DBG_INFO, opts=opts)
    assert outputs['epart'].size == ne
    assert outputs['npart'].size == nv
    assert sum([np.where(outputs['epart'] == x)[0].size
                for x in range(4)]) == ne


def test_options2():
    nv, ne, eptr, eind = load_mesh()
    opts = Options()
    opts.objtype = OBJTYPE_VOL
    outputs = part_mesh(nv, eptr, eind, 4, ncommon=3, elemental=False,
                        debug=DBG_INFO, opts=opts)
    assert outputs['epart'].size == ne
    assert outputs['npart'].size == nv
    assert sum([np.where(outputs['npart'] == x)[0].size
                for x in range(4)]) == nv
