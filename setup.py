#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import subprocess
from distutils.core import setup, Extension


GENERATE_C = True
GENERATE_C_CMD = "cython -3 -a lirc/lirc.pyx"


class InstallFailed(Exception):
    pass


def run_cmd(cmd, error_msg):
    success = subprocess.call([cmd], shell=True)
    if success != 0:
        raise InstallFailed(error_msg)


if "install" in sys.argv and GENERATE_C:
    run_cmd(GENERATE_C_CMD, "Failed to generate C from Cython.")


lirc_ext = Extension(
    'lirc',
    include_dirs=['/usr/include/lirc/'],
    libraries=['lirc/lirc_client'],
    library_dirs=['/usr/lib'],
    sources=['lirc/lirc.c']
)

setup(
    name='python-lirc',
    version='1.0',
    description='Python bindings for LIRC.',
    author='Thomas Preston',
    author_email='thomasmarkpreston@gmail.com',
    license='GPLv3+',
    url='https://github.com/tompreston/python-lirc',
    ext_modules=[lirc_ext],
    long_description="Python LIRC extension written in Cython for Python 3 "
        "(and 2).",
    classifiers=[
        "License :: OSI Approved :: GNU Affero General Public License v3 or "
        "later (AGPLv3+)",
        "Programming Language :: Cython",
        "Development Status :: 5 - Production/Stable",
        "Intended Audience :: Developers",
        "Topic :: Software Development :: Libraries :: Python Modules",
    ],
    keywords='lirc cython remote ir infrared',
)
