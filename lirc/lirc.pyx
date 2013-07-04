#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
lirc.pyx
Provides a Python API for the lirc libraries
Copyright (C) 2013 thomasmarkpreston@gmail.com

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
"""
from libc.stdlib cimport calloc, free
from posix cimport fcntl, unistd
cimport lirc_client


ENCODING = 'utf-8'
STRING_BUFFER_LEN = 256
LOCAL_CONFIG_FILE = "~/.lircrc"
GLOBAL_CONFIG_FILE = "/etc/lirc/lircrc"

initialised = False
config = None


class InitError(Exception):
    pass


class DeinitError(Exception):
    pass


class ConfigLoadError(Exception):
    pass


class Code2CharError(Exception):
    pass


class NextCodeError(Exception):
    pass


class NoMoreStrings(Exception):
    pass


cdef class LircConfig:
    cdef lirc_client.lirc_config * _c_lirc_config

    def __cinit__(self, config_filename):
        self.add_config_file(config_filename)

    def __dealloc__(self):
        if self._c_lirc_config is not NULL:
            lirc_client.lirc_freeconfig(self._c_lirc_config)

    def add_config_file(self, config_filename):
        if config_filename is not None:
            lirc_client.lirc_readconfig(
                config_filename, &self._c_lirc_config, NULL)
        else:
            lirc_client.lirc_readconfig(
                NULL, &self._c_lirc_config, NULL)

        if self._c_lirc_config is NULL:
            raise ConfigLoadError(
                "Could not load the config file (%s)" % config_filename)

    def code2char(self, char * code):
        """Returns the (byte) string associated with the code in the
        config file
        """
        self.is_init_or_error()

        cdef char * string_buf = \
            <char * >calloc(STRING_BUFFER_LEN, sizeof(char))
        cdef char * string_buf_2 = string_buf  # string_buf might be destroyed

        status = lirc_client.lirc_code2char(
            self._c_lirc_config, code, &string_buf)

        if status == -1:
            free(string_buf)
            raise Code2CharError(
                "There was an error determining the config string.")

        if string_buf == NULL:
            free(string_buf_2)
            raise NoMoreStrings()
        else:
            string = string_buf.decode(ENCODING)
            free(string_buf_2)
            return string

    def is_init_or_error(self):
        """Throws an error if not initialised"""
        if self._c_lirc_config is NULL:
            raise InitError("LircConfig has not been inititalised.")


def init(program_name, config_filename=None, blocking=True, verbose=False):
    global initialised
    if initialised:
        return

    # init lirc
    b_program_name = program_name.encode(ENCODING)
    lirc_socket = lirc_client.lirc_init(b_program_name, 1 if verbose else 0)
    if lirc_socket == -1:
        raise InitError(
            "Unable to initialise lirc (socket was -1 from C library).")

    set_blocking(blocking, lirc_socket)
    initialised = True

    if config_filename:
        load_config_file(config_filename)
    else:
        try:
            load_default_config()
        except ConfigLoadError as e:
            raise InitError("Unable to load default config {} or {}.".format(
                    LOCAL_CONFIG_FILE, GLOBAL_CONFIG_FILE)) from e

    return lirc_socket


def deinit():
    global initialised
    if not initialised:
        return

    if lirc_client.lirc_deinit() == -1:
        raise DeinitError("Unable to de-initialise lirc.")
    config = None
    initialised = False


def load_default_config():
    """Attempts to load the default lirc config files."""
    try:
        load_config_file(LOCAL_CONFIG_FILE)
    except ConfigLoadError as local_conf_error:
        try:
            load_config_file(GLOBAL_CONFIG_FILE)
        except ConfigLoadError as global_conf_error:
            raise global_conf_error from local_conf_error


def load_config_file(config_filename=None):
    """Adds a configuration file for this instance of lirc."""
    _is_init_or_error()

    # read config
    if config_filename:
        b_config_filename = config_filename.encode(ENCODING)
    else:
        b_config_filename = None

    global config
    if config:
        config.add_config_file(b_config_filename)
    else:
        config = LircConfig(b_config_filename)


def nextcode():
    """Returns the list of codes in the lirc queue.
    May block, depending on initialisation parameters
    """
    _is_init_or_error()

    cdef char * code
    if lirc_client.lirc_nextcode(&code) == -1:
        free(code)
        raise NextCodeError("There was an error reading the next code.")
    if code == NULL:
        raise NextCodeError("There was no complete code available.")

    # get all of the strings associated with this code
    strings = list()
    while True:
        global config
        try:
            strings.append(config.code2char(code))
        except NoMoreStrings:
            break

    free(code)
    return strings


def set_blocking(blocking, lirc_socket):
    """Sets whether the nextcode function blocks"""
    fcntl.fcntl(lirc_socket, fcntl.F_SETOWN, unistd.getpid())
    flags = fcntl.fcntl(lirc_socket, fcntl.F_GETFL, 0)
    if(flags == 0):
        fcntl.fcntl(
            lirc_socket,
            fcntl.F_SETFL,
            (flags & ~fcntl.O_NONBLOCK) | (0 if blocking else fcntl.O_NONBLOCK)
        )


def _is_init_or_error():
    global initialised
    if not initialised:
        raise InitError("%s has not been initialised." % __name__)
