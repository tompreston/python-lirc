python-lirc
===========

LIRC extension written in Cython for Python 3 (and 2).

I'm trying to get this into
[Debian](http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=Bug%23718980)

[PyPI](https://pypi.python.org/pypi/python-lirc/)

Install
=======

Download the latest relase from
[here](https://github.com/tompreston/python-lirc/releases) and install with:

    $ sudo dpkg -i python3-lirc_1.2.0-1_all.deb


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

Use
===

    $ python3
    >>> import lirc
    >>> sockid = lirc.init("myprogram")
    >>> lirc.nextcode()  # press 1 on remote after this
    ['one', 'horse']
    >>> lirc.deinit()

Load custom configurations with:

    >>> sockid = lirc.init("myprogram", "mylircrc")
    >>> lirc.load_config_file("another-config-file") # subsequent configs

Set whether nextcode blocks or not with:

    >>> sockid = lirc.init("myprogram", blocking=False)
    >>> lirc.set_blocking(True, sockid)  # or this


Building and Installing
=======================
If you want to install manually then you may also need to install
cython and some dev libraries:

    $ sudo aptitude install liblircclient-dev cython gcc

Download, compile and install for Python 3 and 2.

    git clone https://github.com/tompreston/python-lirc.git
    cd python-lirc/
    make py3 && sudo python3 setup.py install
    make py2 && sudo python setup.py install

Or just install straight from PyPI:

    sudo easy_install3 python-lirc
    sudo easy_install python-lirc
