from distutils.core import setup
from distutils.extension import Extension
import re
import numpy


vfile = open('pymetis_mesh/_version.py', mode='r')
vstr_raw = vfile.read()
vstr_find = re.search(r"^__version__ = ['\"]([^'\"]*)['\"]", vstr_raw, re.M)
if vstr_find:
    version = vstr_find.group(1)
else:
    raise RuntimeError(
        'Unable to find __version__ in pymetis_mesh/_version.py.')
vfile.close()

_inc_dirs = [
    numpy.get_include(),
]

ext = Extension(
    'pymetis_mesh._wrapper',
    ['pymetis_mesh/_wrapper.c'],
    include_dirs=_inc_dirs,
    extra_compile_args=['-w', '-march=native', '-O3'],
)

classifiers = [
    'Programming Language :: Python',
    'Programming Language :: Python :: 2.7',
    'Programming Language :: Python :: 3.5',
    'Programming Language :: Python :: 3.6',
    'Topic :: Scientific/Engineering',
    'Topic :: Software Development',
    'Operating System :: Linux',
    'Intended Audience :: Science/Research',
]


setup(
    name='pymetis_mesh',
    version=version,
    description='Partitioning Finite Element Meshes with METIS in Python',
    author='Qiao Chen',
    author_email='benechiao@gmail.com',
    keywords='Math',
    packages=['pymetis_mesh'],
    ext_modules=[ext],
    classifiers=classifiers,
)
