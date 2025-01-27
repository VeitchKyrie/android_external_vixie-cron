#/* Copyright 1988,1990,1993,1994 by Paul Vixie
# * All rights reserved
# */

##
## Copyright (c) 2004 by Internet Systems Consortium, Inc. ("ISC")
## Copyright (c) 1997,2000 by Internet Software Consortium, Inc.
##
## Permission to use, copy, modify, and distribute this software for any
## purpose with or without fee is hereby granted, provided that the above
## copyright notice and this permission notice appear in all copies.
##
## THE SOFTWARE IS PROVIDED "AS IS" AND ISC DISCLAIMS ALL WARRANTIES
## WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
## MERCHANTABILITY AND FITNESS.  IN NO EVENT SHALL ISC BE LIABLE FOR
## ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
## WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
## ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT
## OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
##

# Makefile for ISC cron
#
# $Id: Makefile,v 1.9 2004/01/23 18:56:42 vixie Exp $
#
# vix 03mar88 [moved to RCS, rest of log is in there]
# vix 30mar87 [goodbye, time.c; hello, getopt]
# vix 12feb87 [cleanup for distribution]
# vix 30dec86 [written]

# NOTES:
#	'make' can be done by anyone
#	'make install' must be done by root
#
#	this package needs getopt(3), bitstring(3), and BSD install(8).
#
#	the configurable stuff in this makefile consists of compilation
#	options (use -O, cron runs forever) and destination directories.
#	SHELL is for the 'augumented make' systems where 'make' imports
#	SHELL from the environment and then uses it to run its commands.
#	if your environment SHELL variable is /bin/csh, make goes real
#	slow and sometimes does the wrong thing.  
#
#	this package needs the 'bitstring macros' library, which is
#	available from me or from the comp.sources.unix archive.  if you
#	put 'bitstring.h' in a non-standard place (i.e., not intuited by
#	cc(1)), you will have to define INCLUDE to set the include
#	directory for cc.  INCLUDE should be `-Isomethingorother'.
#
#	there's more configuration info in config.h; edit that first!

#################################### begin configurable stuff
#<<DESTROOT is assumed to have ./etc, ./bin, and ./man subdirectories>>
DESTROOT	=	$(DESTDIR)/usr
DESTSBIN	=	$(DESTROOT)/sbin
DESTBIN		=	$(DESTROOT)/bin
DESTMAN		=	$(DESTROOT)/share/man
#<<need bitstring.h>>
INCLUDE		=	-I. -I../../../FAW-VW-CRS3.0-MQB-System-Sdk/sysroots/armv7ahf-neon-linux-gnueabi/usr/include 
#INCLUDE	=
#<<need getopt()>>
LIBS		= 
#<<optimize or debug?>>
#CDEBUG		=	-O
CDEBUG		=	-g
#<<lint flags of choice?>>
LINTFLAGS	=	-hbxa $(INCLUDE) $(DEBUGGING)
#<<want to use a nonstandard CC?>>
#CC		=	./agcc -mabi=aapcs-linux -Wall -Wno-unused -Wno-comment
CC          = arm-linux-gnueabihf-gcc
#<<manifest defines>>
DEFS		=
#(SGI IRIX systems need this)
#DEFS		=	-D_BSD_SIGNALS -Dconst=
#<<the name of the BSD-like install program>>
#INSTALL = installbsd
INSTALL = install
#<<any special load flags>>
LDFLAGS		= -L../../../FAW-VW-CRS3.0-MQB-System-Sdk/sysroots/armv7ahf-neon-linux-gnueabi/usr/lib 
#################################### end configurable stuff

SHELL		=	/bin/sh
CFLAGS		=	$(CDEBUG) $(INCLUDE) $(DEFS)

INFOS		=	README CHANGES FEATURES INSTALL CONVERSION THANKS MAIL
MANPAGES	=	bitstring.3 crontab.5 crontab.1 cron.8 putman.sh
HEADERS		=	bitstring.h cron.h config.h pathnames.h externs.h \
			macros.h structs.h funcs.h globals.h
SOURCES		=	cron.c crontab.c database.c do_command.c entry.c \
			env.c job.c user.c popen.c misc.c pw_dup.c
SHAR_SOURCE	=	$(INFOS) $(MANPAGES) Makefile $(HEADERS) $(SOURCES)
LINT_CRON	=	cron.c database.c user.c entry.c \
			misc.c job.c do_command.c env.c popen.c pw_dup.c
LINT_CRONTAB	=	crontab.c misc.c entry.c env.c
CRON_OBJ	=	cron.o database.o user.o entry.o job.o do_command.o \
			misc.o env.o popen.o pw_dup.o
CRONTAB_OBJ	=	crontab.o misc.o entry.o env.o pw_dup.o

all		:	cron crontab

lint		:
			lint $(LINTFLAGS) $(LINT_CRON) $(LIBS) \
			|grep -v "constant argument to NOT" 2>&1
			lint $(LINTFLAGS) $(LINT_CRONTAB) $(LIBS) \
			|grep -v "constant argument to NOT" 2>&1


cron		:	$(CRON_OBJ)
			$(CC) $(LDFLAGS) -o cron $(CRON_OBJ) $(LIBS)

#vpath %.o /work/sdk/FAW-VW-CRS3.0-37W-Soc/FAW-VW-CRS3.0-37W-System-Sdk/sysroots/armv7ahf-neon-linux-gnueabi/usr/lib

crontab		:	$(CRONTAB_OBJ)
			$(CC) $(LDFLAGS) -o crontab $(CRONTAB_OBJ) $(LIBS)

install		:	all
			$(INSTALL) -c -m  111 -o root -s cron    $(DESTSBIN)/
			$(INSTALL) -c -m 4111 -o root -s crontab $(DESTBIN)/
#			$(INSTALL) -c -m  111 -o root -g crontab -s cron $(DESTSBIN)/
#			$(INSTALL) -c -m 2111 -o root -g crontab -s crontab $(DESTBIN)/
			sh putman.sh crontab.1 $(DESTMAN)
			sh putman.sh cron.8    $(DESTMAN)
			sh putman.sh crontab.5 $(DESTMAN)

distclean	:	clean
			rm -f *.orig *.rej *.BAK *.CKP *~ #*
			rm -f a.out core tags

clean		:
			rm -f *.o
			rm -f cron crontab
            $(shell ln -s ../../../../FAW-VW-CRS3.0-37W-Soc/FAW-VW-CRS3.0-37W-System-Sdk/sysroots/armv7ahf-neon-linux-gnueabi/usr/lib/crtn.o)
            $(shell ln -s ../../../../FAW-VW-CRS3.0-37W-Soc/FAW-VW-CRS3.0-37W-System-Sdk/sysroots/armv7ahf-neon-linux-gnueabi/usr/lib/crti.o)
            $(shell ln -s ../../../../FAW-VW-CRS3.0-37W-Soc/FAW-VW-CRS3.0-37W-System-Sdk/sysroots/armv7ahf-neon-linux-gnueabi/usr/lib/crt1.o )
    
tags		:;	ctags ${SOURCES}

kit		:	$(SHAR_SOURCE)
			shar $(SHAR_SOURCE) >kit

$(CRON_OBJ)	:	cron.h config.h externs.h pathnames.h Makefile
$(CRONTAB_OBJ)	:	cron.h config.h externs.h pathnames.h Makefile
