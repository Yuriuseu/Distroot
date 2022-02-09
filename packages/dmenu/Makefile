# DMenu - Dynamic Menu
# See LICENSE file for copyright and license details.

# DMenu version
VERSION = 5.0

# Directory paths
PREFIX = /usr
MANPREFIX = $(PREFIX)/share/man

# Includes and libraries
INCLUDES = -I/usr/lib/include -I/usr/include/freetype2
LIBS = -L/usr/lib -lX11 -lXinerama -lfontconfig -lXft

# Flags
CPPFLAGS = -D_DEFAULT_SOURCE -D_BSD_SOURCE -D_XOPEN_SOURCE=700 -D_POSIX_C_SOURCE=200809L -DVERSION=\"$(VERSION)\" -DXINERAMA
CFLAGS = -std=c99 -pedantic -Wall -Os $(INCLUDES) $(CPPFLAGS)
LDFLAGS = $(LIBS)

# Compiler and linker
CC = cc

# Default shell
SHELL = /usr/bin/bash

all: dmenu stest

%.o: %.c ${wildcard *.h}
	${CC} ${CFLAGS} -c $<

%: %.o
	${CC} ${LDFLAGS} $^ -o $@

dmenu: %: dmenu.o drw.o util.o

stest: %: stest.o

clean:
	rm -rf dmenu stest *.o \
		pkg src *.pkg.tar.xz

install: all
	install -D -m 0755 dmenu dmenu_path dmenu_run stest -t ${DESTDIR}${PREFIX}/bin
	install -D -m 0644 <(sed "s/VERSION/${VERSION}/g" dmenu.1) ${DESTDIR}${MANPREFIX}/man1/dmenu.1
	install -D -m 0644 <(sed "s/VERSION/${VERSION}/g" stest.1) ${DESTDIR}${MANPREFIX}/man1/stest.1

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/{dmenu,dmenu_path,dmenu_run,stest} \
		${DESTDIR}${MANPREFIX}/man1/{dmenu,stest}.1

.PHONY: all clean install uninstall
