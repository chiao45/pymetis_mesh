# add pymetis_mesh if inplace
import sys
sys.path.append('../')
from pymetis_mesh import *
import numpy as np


def load_mesh():
    import csv
    f = open('tet.csv')
    reader = csv.reader(f, delimiter=' ')
    _eind = []
    for line in reader:
        _eind += [int(x) for x in line]
    _nv = max(_eind) + 1
    _ne = len(_eind) // 4
    return (
        _nv, _ne,
        np.asarray(np.arange(0, len(_eind) + 4, 4), dtype='int32'),
        np.asarray(_eind, dtype='int32')
    )


nv, ne, eptr, eind = load_mesh()


def test_ce():
    outputs = part_mesh(nv, eptr, eind, 4)
    assert outputs['epart'].size == ne
    assert outputs['npart'].size == nv
    assert sum([np.where(outputs['epart'] == x)[0].size
                for x in range(4)]) == ne


def test_cn():
    outputs = part_mesh(nv, eptr, eind, 4, elemental=False)
    assert outputs['epart'].size == ne
    assert outputs['npart'].size == nv
    assert sum([np.where(outputs['npart'] == x)[0].size
                for x in range(4)]) == nv


def test_fe():
    outputs = part_mesh(nv, eptr + 1, eind + 1, 4, one_base=True)
    assert outputs['epart'].size == ne
    assert outputs['npart'].size == nv
    assert sum([np.where(outputs['epart'] == x)[0].size
                for x in [1, 2, 3, 4]]) == ne


def test_fn():
    outputs = part_mesh(nv, eptr + 1, eind + 1, 4,
                        elemental=False, one_base=True)
    assert outputs['epart'].size == ne
    assert outputs['npart'].size == nv
    assert sum([np.where(outputs['npart'] == x)[0].size
                for x in [1, 2, 3, 4]]) == nv
