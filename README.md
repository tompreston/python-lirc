python-lirc
===========

[PyPI](https://pypi.python.org/pypi/python-lirc/)

Install
=======

    pip3 install python3-lirc

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

Set whether `nextcode` blocks or not with:

    >>> sockid = lirc.init("myprogram", blocking=False)
    >>> lirc.set_blocking(True, sockid)  # or this


Building and Installing
=======================
If you want to install manually then you may also need to install
cython and some dev libraries:

    sudo apt install cython gcc liblircclient-dev python{,3}-{dev,setuptools}

Download, compile and install for Python 3 and 2.

    git clone https://github.com/tompreston/python-lirc.git
    cd python-lirc/
    make py3 && sudo python3 setup.py install
    make py2 && sudo python setup.py install

Development
===========
1. Install the dev libraries as above.
2. Make changes to `lirc/lirc.pyx`.
3. Compile with `make py3 && python3 setup.py build`
4. Test with `python3 tests/tests.py`
