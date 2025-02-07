#
# Makefile for pdisk
#

MAN_PAGE= \
	pdisk.8

MAC_DOC= \
	pdisk.html

DOCS= \
	HISTORY \
	README \
	$(MAN_PAGE) \
	$(MAC_DOC)

SERVER_README = \
	dist.README

SERVER_MESSAGE = \
	dist.message

DOCS_INTERNAL= \
	HISTORY.ALL \
	HOWTO.DISTRIBUTE \
	To_do_list \
	command-language

SUPPORT= \
	make_filename \
	make_depend \
	make_tags \
	checkin_files \
	MPWcompare \
	name_latest \
	next_release

MAC_SOURCE= \
	ATA_media.c \
	ATA_media.h \
	DoSCSICommand.c \
	DoSCSICommand.h \
	MacSCSICommand.h \
	SCSI_media.c \
	SCSI_media.h \
	pdisk.r

UNIX_SOURCE= \
	bitfield.c \
	bitfield.h \
	cmdline.c \
	cmdline.h \
	convert.c \
	convert.h \
	cvt_pt.c \
	deblock_media.c \
	deblock_media.h \
	dpme.h \
	dump.c \
	dump.h \
	errors.c \
	errors.h \
	file_media.c \
	file_media.h \
	hfs_misc.c \
	hfs_misc.h \
	io.c \
	io.h \
	layout_dump.c \
	layout_dump.h \
	makefile \
	media.c \
	media.h \
	partition_map.c \
	partition_map.h \
	pathname.c \
	pathname.h \
	pdisk.c \
	pdisk.h \
	util.c \
	util.h \
	validate.c \
	validate.h \
	version.h

COMMON_OBJECTS = \
	partition_map.o \
	bitfield.o \
	convert.o \
	deblock_media.o \
	file_media.o \
	errors.o \
	hfs_misc.o \
	io.o \
	media.o \
	pathname.o \
	util.o

UNIX_OBJECTS = \
	pdisk.o \
	dump.o \
	cmdline.o \
	$(COMMON_OBJECTS) \
	validate.o

CVT_OBJECTS = \
	cvt_pt.o \
	cmdline.o \
	dump.o \
	$(COMMON_OBJECTS)



ALL_FILES= $(DOCS) $(DOCS_INTERNAL) $(SUPPORT) $(MAC_SOURCE) $(UNIX_SOURCE)

UNIX_BINARIES= \
	pdisk \
	cvt_pt

#
# these names have '__' in place of ' ' to avoid quoting nightmares 
#
MAC_PROJECT= \
	pdisk.mac.bin \
	pdisk.mac__Data/CW__Settings.stm.bin \
	pdisk.mac__Data/pdisk.tdm.bin \
	pdisk.mac__Data/pdisk__68k.tdm.bin

# Constructed under MacOS using CodeWarrior from MAC_PROJECT & sources
MAC_BINARY= \
	pdisk.hqx

MAC_68KBINARY= \
	pdisk_68k.hqx


CFLAGS = -Wall -D__unix__
DIST_TAR_FLAGS = cvf


all: $(UNIX_BINARIES)

pdisk: $(UNIX_OBJECTS)
	cc -o pdisk -lbsd $(UNIX_OBJECTS)

cvt_pt: $(CVT_OBJECTS)
	cc -o cvt_pt -lbsd $(CVT_OBJECTS)

tags:	$(MAC_SOURCE) $(UNIX_SOURCE)
	ctags $(MAC_SOURCE) $(UNIX_SOURCE)

clean:
	rm -f *.o $(UNIX_BINARIES) list.src

clobber:	clean
	rm -f $(ALL_FILES) $(MAC_BINARY) $(MAC_68KBINARY) tags

# note the sed to reinsert the spaces in the Mac names
list.src: $(MAC_SOURCE) $(DOCS) $(UNIX_SOURCE) $(MAC_PROJECT)
	echo $(MAC_SOURCE) $(DOCS) $(UNIX_SOURCE) $(MAC_PROJECT) |\
	tr ' ' '\n' | sed -e 's/__/ /g' -e 's,^,pdisk/,' >list.src

#
# this depends on this source directory being named 'pdisk'
#
distribution: list.src
	cd ..; tar $(DIST_TAR_FLAGS) pdisk/dist/pdisk.src.tar.`date +%Y%m%d` --files-from pdisk/list.src
	tar $(DIST_TAR_FLAGS) dist/pdisk.bin.tar.`date +%Y%m%d` $(UNIX_BINARIES) $(MAN_PAGE)
	cp -f $(MAC_DOC) dist/$(MAC_DOC).`date +%Y%m%d`
	cp -f $(MAC_BINARY) dist/$(MAC_BINARY).`date +%Y%m%d`
	cp -f $(MAC_68KBINARY) dist/$(MAC_68KBINARY).`date +%Y%m%d`

checkin:
	./checkin_files $(ALL_FILES)

checkout:	$(ALL_FILES)

diff:
	rcsdiff $(ALL_FILES) 2>&1

name:
	./name_latest $(ALL_FILES)

#
# in lieu of a real dependency generator
#
convert.h:	dpme.h
deblock_media.h:	media.h
dpme.h:	bitfield.h
dump.h:	partition_map.h hfs_misc.h
file_media.h:	media.h
partition_map.h:	dpme.h media.h
pathname.h:	media.h
validate.h:	partition_map.h

bitfield.o:	bitfield.c bitfield.h
convert.o:	convert.c convert.h
deblock_media.o:	deblock_media.c deblock_media.h
dump.o:		dump.c dump.h pathname.h io.h errors.h
errors.o:	errors.c errors.h
file_media.o:	file_media.c file_media.h errors.h
io.o:		io.c io.h errors.h
layout_dump.o:	layout_dump.c layout_dump.h
media.o:	media.c media.h
partition_map.o:	partition_map.c partition_map.h pathname.h deblock_media.h io.h convert.h util.h errors.h
pathname.o:	pathname.c pathname.h file_media.h
pdisk.o:	pdisk.c pdisk.h io.h partition_map.h pathname.h errors.h dump.h validate.h version.h util.h
util.o:		util.c version.h util.h
validate.o:	validate.c validate.h deblock_media.h pathname.h convert.h io.h errors.h


#
# fake dependencies used only by list.src {for $(MAC_PROJECT)}
#
pdisk.mac__Data/CW__Settings.stm.bin:
pdisk.mac__Data/pdisk.tdm.bin:
pdisk.mac__Data/pdisk__68k.tdm.bin:
