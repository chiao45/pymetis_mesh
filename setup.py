from setuptools import setup, Extension
import re
import numpy
import glob
import os
import sys
import codecs


vfile = open('pymetis_mesh/_version.py', mode='r')
vstr_raw = vfile.read()
vstr_find = re.search(r"^__version__ = ['\"]([^'\"]*)['\"]", vstr_raw, re.M)
if vstr_find:
    version = vstr_find.group(1)
else:
    raise RuntimeError(
        'Unable to find __version__ in pymetis_mesh/_version.py.')
vfile.close()


def config_libmetis():
    """Configure metis, decide whether or not use the metis source
    comes with pymetis_mesh"""
    import distutils
    from distutils.ccompiler import get_default_compiler, new_compiler
    import tempfile
    if '--user' in sys.argv:
        is_user = True
    else:
        is_user = False
    if is_user:
        from site import USER_BASE
        metis_root = USER_BASE
        inc_dir = metis_root + os.sep + 'include'
    else:
        metis_root = ''
        inc_dir = ''
    compiler = new_compiler(get_default_compiler())
    tmp_file_name = tempfile.gettempdir() + os.sep + 'foo.c'
    f = open(tmp_file_name, 'w')
    f.write('#include \"metis.h\"\nint main(void){return 0;}')
    f.close()

    def remove():
        try:
            os.remove(tmp_file_name)
        except OSError:
            pass
    try:
        include_dirs = [] if inc_dir == '' else [inc_dir]
        compiler.compile([tmp_file_name], include_dirs=include_dirs)
        remove()
        return True, metis_root
    except distutils.errors.CompileError:
        remove()
        return False, ''


flag_root = config_libmetis()

_inc_dirs = [
    numpy.get_include(),
]

_libs = None
_lib_dir = None
_rpath = None

_srcs = ['pymetis_mesh/_wrapper.c']

if not flag_root[0]:
    _inc_dirs += [
        'pymetis_mesh/src/GKlib',
        'pymetis_mesh/src/libmetis',
        'pymetis_mesh/src/include'
    ]
    _srcs += glob.glob('pymetis_mesh/src/GKlib/*.c') + \
        glob.glob('pymetis_mesh/src/libmetis/*.c')
elif flag_root[1] != '':
    _inc_dirs += [flag_root[1] + os.sep + 'include']
    _libs = ['metis']
    _lib_dir = [flag_root[1] + os.sep + 'lib']
    _rpath = [flag_root[1] + os.sep + 'lib']
else:
    _libs = ['metis']


install_requires = [
    'numpy',
]

ext = Extension(
    'pymetis_mesh._wrapper',
    _srcs,
    include_dirs=_inc_dirs,
    extra_compile_args=['-w', '-O3'],
    libraries=_libs,
    library_dirs=_lib_dir,
    runtime_library_dirs=_rpath
)

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
    packages=['pymetis_mesh'],
    package_data={
        'pymetis_mesh': [
            '*.pxd',
            '*.pyx',
            'src/GKlib/*',
            'src/include/*',
            'src/libmetis/*'
        ]
    },
    install_requires=install_requires,
    ext_modules=[ext],
    classifiers=classifiers
)
