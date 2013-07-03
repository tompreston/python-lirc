python-lirc
===========

LIRC extension written in Cython for Python 3 (and 2).
[PyPI](https://pypi.python.org/pypi/python-lirc/)


Install
=======

You'll need to have lirc configured. There are some [decent instructions here](http://learn.adafruit.com/using-an-ir-remote-with-a-raspberry-pi-media-center/lirc).

    $ sudo aptitude install cython gcc lirc
    $ git clone https://github.com/tompreston/python-lirc.git
    $ cd python-lirc/
    $ sudo python3 setup.py install


Configure
=========

You need a valid [lircrc configuration file](http://www.lirc.org/html/configure.html#lircrc_format). For example:

    $ cat ~/.lircrc
    begin
      button = 1          # what button is pressed on the remote
      prog = myprogram    # program to handle this command
      config = one, horse # configs are given to program as list
    end

    begin
      button = 2
      prog = myprogram
      config = two
    end

    begin
      button = 3
      prog = myprogram
      config = three
    end

Use
===

    $ python3
    >>> import lirc
    >>> sockid = lirc.init("myprogram")
    >>> lirc.nextcode()  # press 1 on remote after this
    ['one', 'horse']
    >>> lirc.deinit()

Load custom configurations with:

    >>> lirc.load_config_file("another-config-file")

Set whether nextcode blocks or not with:

    >>> sockid = lirc.init("myprogram")
    >>> lirc.set_blocking(True, sockid)