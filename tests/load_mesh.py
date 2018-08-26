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
