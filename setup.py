import re
import glob
import os
import codecs
import numpy
from setuptools import setup, Extension, find_packages


_join = os.path.join
vfile = open(_join('pymetis_mesh', '_version.py'), mode='r')
vstr_raw = vfile.read()
vstr_find = re.search(r"^__version__ = ['\"]([^'\"]*)['\"]", vstr_raw, re.M)
if vstr_find:
    version = vstr_find.group(1)
else:
    raise RuntimeError(
        'Unable to find __version__ in pymetis_mesh/_version.py.')
vfile.close()


# meta data

install_requires = [
    'numpy',
    'setuptools',
]
package_data = {
    'pymetis_mesh': [
        '*.pxd',
        '*.pyx',
        _join('src', 'include', '*'),
        _join('src', 'libparmetis', '*'),
        _join('src', 'metis', 'GTKlib', '*'),
        _join('src', 'metis', 'include', '*'),
        _join('src', 'metis', 'libmetis', '*'),
    ]
}
classifiers = [
    'Programming Language :: Python',
    'Programming Language :: Python :: 2.7',
    'Programming Language :: Python :: 3.4',
    'Programming Language :: Python :: 3.5',
    'Programming Language :: Python :: 3.6',
    'License :: OSI Approved :: MIT License',
    'Topic :: Scientific/Engineering',
    'Topic :: Software Development',
    'Operating System :: POSIX :: Linux',
    'Intended Audience :: Science/Research',
]


def gen_metis_ext():
    _src_root = _join('pymetis_mesh', 'src')
    _metis_src = _join(_src_root, 'metis')
    _srcs = [_join('pymetis_mesh', '_wrapper.c')]
    _srcs += glob.glob(_join(_metis_src, 'GKlib', '*.c')) + \
        glob.glob(_join(_metis_src, 'libmetis', '*.c'))
    _inc_dirs = [
        numpy.get_include(),
        _join(_metis_src, 'GKlib'),
        _join(_metis_src, 'libmetis'),
        _join(_metis_src, 'include'),
    ]
    return [Extension('pymetis_mesh._wrapper', _srcs, include_dirs=_inc_dirs,)]


exts = gen_metis_ext()


setup(
    name='pymetis_mesh',
    version=version,
    description='Partitioning Finite Element Meshes with METIS in Python',
    long_description=codecs.open('README.rst', encoding='utf-8').read(),
    author='Qiao Chen',
    author_email='benechiao@gmail.com',
    keywords='Math',
    license='MIT',
    url='https://github.com/chiao45/pymetis_mesh',
    packages=find_packages(),
    package_data=package_data,
    install_requires=install_requires,
    ext_modules=exts,
    classifiers=classifiers
)
