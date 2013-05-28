python-lirc
===========

Python LIRC extension written in Cython for Python 3 (and 2).

There was no good support for LIRC in Python 3. Cython is fast, modern and
backwards-compatible. :-)

Please test if you have an IR receiver.

Dependencies
============

    $ aptitude install cython gcc lirc

You'll need to have lirc configured. There are some [decent instructions here](http://learn.adafruit.com/using-an-ir-remote-with-a-raspberry-pi-media-center/lirc).

Building & Installing
=====================
Generate the C code:

    $ cython -3 -a lirc.pyx

Compile and link:

    $ gcc -pthread -fno-strict-aliasing -DNDEBUG -g -fwrapv -O2 -Wall -Wstrict-prototypes -I/usr/include/lirc/ -fPIC -I/usr/include/python3.2 -c lirc.c -o lirc.o
    $ gcc -pthread -shared -Wl,-O1 -Wl,-Bsymbolic-functions -Wl,-z,relro -L/usr/lib/ -L/usr/lib/ -I/usr/include/lirc/ lirc.o -llirc_client -o lirc.so

lirc.so is the extension. I'll get a Makefile up soon.


Examples
========
You need a configuration file in the lirc format. I've included an example one.

    $ cat example_config 
    begin
      remote = *
      button = 1          # what button is pressed on the remote
      prog = python-lirc  # program tag to handle this command
      config = one        # string given
    end

    begin
      remote = *
      button = 2
      prog = python-lirc
      config = two
    end

    begin
      remote = *
      button = 3
      prog = python-lirc
      config = three
    end

Here is how you set it up:

    $ python3
    >>> import lirc
    >>> lirc.init("python-lirc")  # this is the program tag (returns socket #)
    3
    >>> lirc.load_config_file("./example_config")

`lirc.nextcode()` will block and return a list of the strings given in the config.

    >>> lirc.nextcode()
    # press 1 on remote
    ['one']
