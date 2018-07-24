# Partition *finite element* meshes with METIS in Python

This repository contains a simple wrapper of `METIS_PartMeshDual` and `METIS_PartMeshNodal`, which can partition finite element unstructured meshes either element-wisely or node-wisely, resp. The wrapper script is written in Cython, and the C code has been already generated. Notice that regenerating the C source code is pretty straightforward.

## Installations

`pymetis_mesh` only requires numpy during installation. Also, tune `setup.cfg` for your metis installation.

## License

MIT License

Copyright (c) 2018 Qiao Chen
