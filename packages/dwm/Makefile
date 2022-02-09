# dwm - dynamic window manager
# See LICENSE file for copyright and license details.

# DWM version
VERSION = 6.2

# Directory paths
PREFIX = /usr
MANPREFIX = ${PREFIX}/share/man

# Includes and libraries
INCLUDES = -I/usr/lib/include -I/usr/include/freetype2
LIBS = -L/usr/lib -lX11 -lXinerama -lfontconfig -lXft

# Flags
CPPFLAGS = -D_DEFAULT_SOURCE -D_BSD_SOURCE -D_POSIX_C_SOURCE=200809L -DVERSION=\"$(VERSION)\" -DXINERAMA
CFLAGS = -std=c99 -pedantic -Wall -Os $(INCLUDES) $(CPPFLAGS)
LDFLAGS = $(LIBS)

# Compiler and linker
CC = cc

# Default shell
SHELL = /usr/bin/bash

all: dwm

%.o: %.c ${wildcard *.h}
	${CC} ${CFLAGS} -c $<

dwm: %: ${patsubst %.c, %.o, ${wildcard *.c}}
	${CC} ${LDFLAGS} $^ -o $@

clean:
	rm -rf dwm *.o \
		pkg src *.pkg.tar.xz

install: all
	install -D -m 0755 -t ${DESTDIR}${PREFIX}/bin dwm
	install -D -m 0644 <(sed "s/VERSION/${VERSION}/g" dwm.1) ${DESTDIR}${MANPREFIX}/man1/dwm.1

uninstall:
	rm -f ${DESTDIR}${PREFIX}/bin/dwm \
		${DESTDIR}${MANPREFIX}/man1/dwm.1

.PHONY: all clean install uninstall
