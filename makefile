py3:
	cython -3 -a lirc/lirc.pyx

py2:
	cython -a lirc/lirc.pyx

clean:
	rm -rf build/
	rm lirc/lirc.c lirc/lirc.html