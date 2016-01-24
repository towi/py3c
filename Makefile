all:
	echo "Available targets:"
	echo "    make test"
	echo "    make test-<interpreter>"
	echo "    make doc"
	echo "    make install"
	echo "    make clean"

prefix ?= /usr/local
includedir ?= $(prefix)/include
datarootdir ?= $(prefix)/share
datadir ?= $(datarootdir)
pkgconfigdir ?= ${datadir}/pkgconfig

doc:
	cd doc && $(MAKE) html

test:
	$(MAKE) test-python2
	$(MAKE) test-python3
	$(MAKE) test-python2-cpp
	$(MAKE) test-python3-cpp

# TODO: A better way to build & use one-off extensions?

build-%:
	cd test; rm -rvf build ; $* setup.py build

build-%-cpp:
	cd test; rm -rvf build ; TEST_USE_CPP=yes $* setup.py build

test-%: build-%
	PYTHONPATH=$(wildcard test/build/lib*) $* test -v

test-%-cpp: build-%-cpp
	TEST_USE_CPP=yes PYTHONPATH=$(wildcard test/build/lib*) $* test -v

py3c.pc: py3c.pc.in
	sed -e's:@includedir@:$(realpath $(includedir)):' $< > $@

install: py3c.pc
	mkdir -p $(includedir)/py3c
	install include/py3c.h $(includedir)/py3c.h
	install $(wildcard include/py3c/*.h) $(includedir)/py3c/

	mkdir -p $(pkgconfigdir)
	install py3c.pc $(pkgconfigdir)/

clean:
	rm py3c.pc ||:

.PHONY: test doc clean install
