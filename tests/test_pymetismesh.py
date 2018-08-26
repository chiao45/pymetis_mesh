# add pymetis_mesh if inplace
import sys
sys.path.append('../')
from pymetis_mesh import *
import numpy as np
from load_mesh import load_mesh


def test_ce():
    nv, ne, eptr, eind = load_mesh()
    outputs = part_mesh(nv, eptr, eind, 4)
    assert outputs['epart'].size == ne
    assert outputs['npart'].size == nv
    assert sum([np.where(outputs['epart'] == x)[0].size
                for x in range(4)]) == ne


def test_cn():
    nv, ne, eptr, eind = load_mesh()
    outputs = part_mesh(nv, eptr, eind, 4, elemental=False)
    assert outputs['epart'].size == ne
    assert outputs['npart'].size == nv
    assert sum([np.where(outputs['npart'] == x)[0].size
                for x in range(4)]) == nv


def test_fe():
    nv, ne, eptr, eind = load_mesh()
    outputs = part_mesh(nv, eptr + 1, eind + 1, 4, one_base=True)
    assert outputs['epart'].size == ne
    assert outputs['npart'].size == nv
    assert sum([np.where(outputs['epart'] == x)[0].size
                for x in [1, 2, 3, 4]]) == ne


def test_fn():
    nv, ne, eptr, eind = load_mesh()
    outputs = part_mesh(nv, eptr + 1, eind + 1, 4,
                        elemental=False, one_base=True)
    assert outputs['epart'].size == ne
    assert outputs['npart'].size == nv
    assert sum([np.where(outputs['npart'] == x)[0].size
                for x in [1, 2, 3, 4]]) == nv
