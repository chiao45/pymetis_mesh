import re
import glob
import os
import codecs
import numpy
from setuptools import setup, Extension, find_packages
from setuptools.command.build_ext import build_ext as _build_ext
try:
    import mpi4py
    BUILD_PAR = True
except ImportError:
    BUILD_PAR = False


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
        '*.c',
        '*.h',
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


# see https://stackoverflow.com/questions/38523941/change-cythons-naming-rules-for-so-files/40193040#40193040
# The following codes try to reuse the symbols in _wrapper module so that
# no dup object files in _parwrapper
def gen_parmetis_ext():
    from distutils.sysconfig import get_config_var
    _ext_suffix = get_config_var('EXT_SUFFIX')
    if _ext_suffix is None:
        # py2
        from distutils.ccompiler import get_default_compiler, new_compiler
        _ext_suffix = new_compiler(get_default_compiler()).shared_lib_extension
    _src_root = _join('pymetis_mesh', 'src')
    _metis_src = _join(_src_root, 'metis')
    _srcs = [_join('pymetis_mesh', '_parwrapper.c')]
    _srcs += glob.glob(_join(_src_root, 'libparmetis', '*.c'))
    _inc_dirs = [
        '.',
        numpy.get_include(),
        mpi4py.get_include(),
        _join(_src_root, 'include'),
        _join(_src_root, 'libparmetis'),
        _join(_metis_src, 'GKlib'),
        _join(_metis_src, 'libmetis'),
        _join(_metis_src, 'include'),
    ]
    # the following one is not portable, but since for MPI runs, most likely
    # we will deal with Linux, and considering the package is built for doing
    # HPC with large PDE problems, it's safe to assume linux
    return [
        Extension(
            'pymetis_mesh._parwrapper',
            _srcs,
            include_dirs=_inc_dirs,
            libraries=['mpi', ':_wrapper{}'.format(_ext_suffix)],
            extra_link_args=['-Wl,-rpath=$ORIGIN/.']
        )
    ]


exts = gen_metis_ext()

if BUILD_PAR:
    # during the building stage, we need to find the temp library to link
    class BuildExt(_build_ext, object):
        def finalize_options(self):
            super(BuildExt, self).finalize_options()
            for ext in self.extensions:
                if ext.name.endswith('_parwrapper'):
                    ext.library_dirs = [
                        self.build_lib + os.sep + 'pymetis_mesh']
                    break
    build_ext = BuildExt
    os.environ['CC'] = mpi4py.get_config()['mpicc']
    exts += gen_parmetis_ext()
else:
    build_ext = _build_ext

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
    classifiers=classifiers,
    cmdclass={'build_ext': build_ext}
)
