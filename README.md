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
Generate the C code and then install using setup.py:

    $ cython -3 -a lirc.pyx
    $ sudo python3 setup.py install

Configuration
=============
You need a configuration file in the lirc format. I've included an example one.

    $ cat example_config 
    begin
      remote = *
      button = 1          # what button is pressed on the remote
      prog = python-lirc  # program tag to handle this command
      config = one, horse # string given
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

Example
=======
Setup:

    $ python3
    >>> import lirc
    >>> sockid = lirc.init("python-lirc")  # arg is program tag
    >>> lirc.load_config_file("./example_config")

Getting the codes:

    >>> lirc.nextcode()  # press 1 on remote after this
    ['one', 'horse']
