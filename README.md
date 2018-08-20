# Partition *finite element* meshes with METIS in Python

[![Build Status](https://travis-ci.org/chiao45/pymetis_mesh.svg?branch=master)](https://travis-ci.org/chiao45/pymetis_mesh)
[![PyPi Version](https://img.shields.io/pypi/v/pymetis_mesh.svg)](https://pypi.org/project/pymetis-mesh/)

This repository contains a simple wrapper of `METIS_PartMeshDual` and `METIS_PartMeshNodal`, which can partition finite element unstructured meshes either element-wisely or node-wisely, resp. The wrapper script is written in Cython, and the C code has been already generated. Notice that regenerating the C source code is pretty straightforward.

## Installations

```bash
pip3 install pymetis_mesh
```

## License

MIT License

Copyright (c) 2018 Qiao Chen
