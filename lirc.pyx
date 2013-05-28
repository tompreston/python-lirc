#!/usr/bin/env python
# -*- coding: utf-8 -*-
from libc.stdlib cimport calloc, free
from posix cimport fcntl, unistd
cimport lirc_client


ENCODING = 'utf-8'
STRING_BUFFER_LEN = 256

initialised = False
config = None


class LircInitError(Exception):
    pass


class LircDeinitError(Exception):
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
    cdef lirc_client.lirc_config* _c_lirc_config

    def __cinit__(self, config_filename):
        self.add_config_file(config_filename)

    def __dealloc__(self):
        if self._c_lirc_config is not NULL:
            lirc_client.lirc_freeconfig(self._c_lirc_config)

    def add_config_file(self, config_filename):
        if config_filename is not None:
            lirc_client.lirc_readconfig(
                config_filename, 
                &self._c_lirc_config, 
                NULL)
        else:
            lirc_client.lirc_readconfig(
                NULL,
                &self._c_lirc_config,
                NULL)

        if self._c_lirc_config is NULL:
            raise ConfigLoadError(
                "Could not load the config file (%s)" % config_filename)

    def code2char(self, char * code):
        """Returns the (byte) string associated with the code in the 
        config file
        """
        self.is_init_or_error()

        cdef char* string_buf = <char*>calloc(STRING_BUFFER_LEN, sizeof(char))
        cdef char* string_buf_2 = string_buf  # string_buf might be destroyed

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
            raise LircInitError("LircConfig has not been inititalised.")


def init(program_name, blocking=True, verbose=False):
    global initialised
    if initialised:
        return

    # init lirc
    b_program_name = bytes(program_name, ENCODING)
    lirc_socket = lirc_client.lirc_init(b_program_name, 1 if verbose else 0)
    if lirc_socket == -1:
        raise LircInitError("Unable to initialise lirc!")

    set_blocking(blocking, lirc_socket)
    initialised = True
    return lirc_socket


def deinit():
    global initialised
    if initialised:
        if lirc_client.lirc_deinit() == -1:
            raise LircDeinitError("Unable to de-initialise lirc!")
        config = None
        initialised = False


def load_config_file(config_filename=None):
    """Adds a configuration file for this instance of lirc"""
    _is_init_or_error()

    # read config
    if config_filename:
        b_config_filename = bytes(config_filename, ENCODING)
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
        try: strings.append(config.code2char(code))
        except NoMoreStrings: break

    free(code)
    return strings


def set_blocking(blocking, lirc_socket):
    """Sets whether the nextcode function blocks"""
    fcntl.fcntl(lirc_socket, fcntl.F_SETOWN, unistd.getpid())
    flags = fcntl.fcntl(lirc_socket, fcntl.F_GETFL, 0);
    if(flags == 0):
        fcntl.fcntl(
            lirc_socket,
            fcntl.F_SETFL,
            (flags & ~fcntl.O_NONBLOCK) |(0 if blocking else fcntl.O_NONBLOCK)
        )

def _is_init_or_error():
    global initialised
    if not initialised:
        raise LircInitError("%s has not been initialised." % __name__)