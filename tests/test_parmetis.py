import numpy as np
from load_mesh import load_mesh
import mpi_helper as mpi
try:
    from pymetis_mesh.parmetis import *
    NO_PARMETIS = False
except ImportError:
    NO_PARMETIS = True

import pytest


@pytest.mark.skipif(NO_PARMETIS or mpi.NO_MPI4PY or mpi.COMM_SIZE != 2, reason='no mpi4py')
def test_parmetis():
    try:
        comm = mpi.comm
        if comm.size != 2:
            mpi.exit_code = 1
            raise RuntimeError('must run on two cores')
        _, ne, _, eind = load_mesh()
        nes = [ne // 2, ne - ne // 2]
        my_ne = nes[comm.rank]
        if comm.rank == 0:
            my_eind = eind[:4 * my_ne].copy()
        else:
            my_eind = eind[4 * nes[0]:].copy()
        eptr = np.arange(0, len(my_eind) + 4, 4, dtype='int32')
        epart = parpart_mesh(eptr, my_eind, comm=comm)['epart']
        # since we know only two cores
        repart_sizes = np.asarray([len(np.where(epart == 0)[0]),
                                   len(np.where(epart == 1)[0])])
        foreign_info = repart_sizes.copy()
        if comm.rank == 0:
            comm.Isend(repart_sizes, dest=1)
            req = comm.Irecv(foreign_info, source=1)
            req.Wait()
        else:
            req = comm.Irecv(foreign_info, source=0)
            req.Wait()
            comm.Isend(repart_sizes, dest=0)
        assert np.sum(repart_sizes + foreign_info) == ne
    except Exception:
        mpi.exit_code = 1
        raise
