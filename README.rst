Partition *finite element* meshes with METIS in Python
=======================================================

.. image:: https://travis-ci.org/chiao45/pymetis_mesh.svg?branch=master
    :target: https://travis-ci.org/chiao45/pymetis_mesh
.. image:: https://img.shields.io/pypi/v/pymetis_mesh.svg?branch=master
    :target: https://pypi.org/project/pymetis-mesh/

Introduction
------------

This repository contains a simple Python wrapper of ``METIS_PartMeshDual`` and
``METIS_PartMeshNodal``, which can partition finite element unstructured meshes
either element-wisely or node-wisely, resp. The wrapper script is written in
Cython, and the C code has been already generated. Notice that regenerating the
C source code is pretty straightforward.

Installation
------------

.. code-block:: console

    $ pip3 install pymetis_mesh

License
-------

MIT License

Copyright (c) 2018 Qiao Chen
