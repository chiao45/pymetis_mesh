# Partition *finite element* meshes with METIS in Python

This repository contains a simple wrapper of `METIS_PartMeshDual` and `METIS_PartMeshNodal`, which can partition finite element unstructured meshes either element-wisely or node-wisely, resp. The wrapper script is written in Cython, and the C code has been already generated. Notice that regenerating the C source code is pretty straightforward.

## Installations

```bash
pip3 install pymetis_mesh
```

## License

MIT License

Copyright (c) 2018 Qiao Chen
