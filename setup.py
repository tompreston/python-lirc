#!/usr/bin/env python
# -*- coding: utf-8 -*-

from distutils.core import setup, Extension

DISTUTILS_DEBUG=True

lirc_ext = Extension('lirc',
    include_dirs = ['/usr/include/lirc/'],
    libraries = ['lirc_client'],
    library_dirs = ['/usr/lib'],
    sources = ['lirc.c']
)

setup(name='python-lirc',
    version='1.0',
    description='Python bindings for LIRC.',
    author='Thomas Preston',
    author_email='thomasmarkpreston@gmail.com',
    license='GPLv3+',
    url='https://github.com/tompreston/python-lirc',
    ext_modules=[lirc_ext],
)