# $Id$

# make Pascal compiler

#PARAMS		do not remove this line!

UTIL_BIN = \
	$(UTIL_HOME)/bin
SRC_DIR = \
	$(SRC_HOME)/lang/pc/comp
FSRC_DIR = \
	$(SRC_HOME)/fast/f_pc

TABGEN=	$(UTIL_BIN)/tabgen
LLGEN =	$(UTIL_BIN)/LLgen
LLGENOPTIONS = \
	-v

SRC_G =	$(SRC_DIR)/program.g $(SRC_DIR)/declar.g \
	$(SRC_DIR)/expression.g $(SRC_DIR)/statement.g
GEN_G =	tokenfile.g
GFILES=	$(GEN_G) $(SRC_G)

SRC_C =	$(SRC_DIR)/LLlex.c $(SRC_DIR)/LLmessage.c $(SRC_DIR)/body.c \
	$(SRC_DIR)/error.c $(SRC_DIR)/label.c $(SRC_DIR)/readwrite.c \
	$(SRC_DIR)/main.c $(SRC_DIR)/tokenname.c $(SRC_DIR)/idf.c \
	$(SRC_DIR)/input.c $(SRC_DIR)/type.c $(SRC_DIR)/def.c \
	$(SRC_DIR)/misc.c $(SRC_DIR)/enter.c $(SRC_DIR)/progs.c \
	$(SRC_DIR)/typequiv.c $(SRC_DIR)/node.c $(SRC_DIR)/cstoper.c \
	$(SRC_DIR)/chk_expr.c $(SRC_DIR)/options.c $(SRC_DIR)/scope.c \
	$(SRC_DIR)/desig.c $(SRC_DIR)/code.c $(SRC_DIR)/lookup.c \
	$(SRC_DIR)/stab.c
GEN_C =	tokenfile.c program.c declar.c expression.c statement.c \
	symbol2str.c char.c Lpars.c casestat.c tmpvar.c next.c
CFILES=	$(SRC_C) $(GEN_C)

SRC_H =	$(SRC_DIR)/LLlex.h $(SRC_DIR)/chk_expr.h $(SRC_DIR)/class.h \
	$(SRC_DIR)/const.h $(SRC_DIR)/debug.h $(SRC_DIR)/f_info.h \
	$(SRC_DIR)/idf.h $(SRC_DIR)/input.h $(SRC_DIR)/main.h \
	$(SRC_DIR)/misc.h $(SRC_DIR)/required.h $(SRC_DIR)/tokenname.h

GEN_H =	errout.h idfsize.h numsize.h strsize.h target_sizes.h \
	inputtype.h density.h nocross.h def.h debugcst.h \
	type.h Lpars.h node.h dbsymtab.h scope.h desig.h

HFILES=	$(GEN_H) $(SRC_H)

NEXTFILES = \
	$(SRC_DIR)/def.H $(SRC_DIR)/type.H $(SRC_DIR)/node.H \
	$(SRC_DIR)/scope.H $(SRC_DIR)/desig.H \
	$(SRC_DIR)/tmpvar.C $(SRC_DIR)/casestat.C

all:		make.main
		make -f make.main main

install:	all
		cp main $(TARGET_HOME)/lib.bin/pc_ce

cmp:		all
		-cmp main $(TARGET_HOME)/lib.bin/pc_ce

opr:
		make pr | opr

pr:
		@pr $(FSRC_DIR)/proto.make $(FSRC_DIR)/proto.main \
			$(FSRC_DIR)/Parameters

lint:		make.main
		make -f make.main lint

Cfiles:		hfiles LLfiles $(GEN_C) $(GEN_H) Makefile
		echo $(CFILES) | tr ' ' '\012' > Cfiles
		echo $(HFILES) | tr ' ' '\012' >> Cfiles

resolved:	Cfiles
		CC="$(CC)" UTIL_HOME="$(UTIL_HOME)" do_resolve `cat Cfiles` > Cfiles.new
		-if cmp -s Cfiles Cfiles.new ; then rm -f Cfiles.new ; else mv Cfiles.new Cfiles ; fi
		touch resolved

# there is no file called "dependencies"; we want dependencies checked 
# every time. This means that make.main is made every time. Oh well ...
# it does not take much time.
dependencies:	resolved
		do_deps `grep '.c$$' Cfiles`

make.main:	dependencies make_macros lists $(FSRC_DIR)/proto.main
		rm_deps $(FSRC_DIR)/proto.main | sed -e '/^.PARAMS/r make_macros' -e '/^.LISTS/r lists' > make.main
		cat *.dep >> make.main

make_macros:    Makefile
		echo 'SRC_DIR=$(SRC_DIR)' > make_macros
		echo 'UTIL_HOME=$(UTIL_HOME)' >> make_macros
		echo 'TARGET_HOME=$(TARGET_HOME)' >> make_macros
		echo 'CC=$(CC)' >> make_macros
		echo 'COPTIONS=$(COPTIONS) -DPEEPHOLE' >> make_macros
		echo 'LDOPTIONS=$(LDOPTIONS)' >> make_macros
		echo 'LINT=$(LINT)' >> make_macros
		echo 'LINTOPTIONS=$(LINTOPTIONS)' >> make_macros
		echo 'LINTSUF=$(LINTSUF)' >> make_macros
		echo 'LINTPREF=$(LINTPREF)' >> make_macros
		echo 'SUF=$(SUF)' >> make_macros
		echo 'LIBSUF=$(LIBSUF)' >> make_macros
		echo 'CC_AND_MKDEP=$(CC_AND_MKDEP)' >> make_macros
		echo 'MACH=$(MACH)' >> make_macros

lists:		Cfiles
		echo "C_SRC = \\" > lists
		echo $(CFILES) >> lists
		echo "OBJ = \\" >> lists
		echo $(CFILES) | sed -e 's|[^ ]*/||g' -e 's/\.c/.$$(SUF)/g' >> lists

clean:
		-make -f make.main clean
		rm -f $(GEN_C) $(GEN_G) $(GEN_H) hfiles LLfiles Cfiles LL.output
		rm -f resolved *.dep lists make.main make_macros

LLfiles:	$(GFILES)
		$(LLGEN) $(LLGENOPTIONS) $(GFILES)
		@touch LLfiles

hfiles:		$(FSRC_DIR)/Parameters $(SRC_DIR)/make.hfiles
		$(SRC_DIR)/make.hfiles $(FSRC_DIR)/Parameters
		touch hfiles

tokenfile.g:	$(SRC_DIR)/tokenname.c $(SRC_DIR)/make.tokfile
		$(SRC_DIR)/make.tokfile <$(SRC_DIR)/tokenname.c >tokenfile.g

symbol2str.c:	$(SRC_DIR)/tokenname.c $(SRC_DIR)/make.tokcase
		$(SRC_DIR)/make.tokcase <$(SRC_DIR)/tokenname.c >symbol2str.c

def.h:		$(SRC_DIR)/make.allocd $(SRC_DIR)/def.H
		$(SRC_DIR)/make.allocd < $(SRC_DIR)/def.H > def.h

type.h:		$(SRC_DIR)/make.allocd $(SRC_DIR)/type.H
		$(SRC_DIR)/make.allocd < $(SRC_DIR)/type.H > type.h

scope.h:	$(SRC_DIR)/make.allocd $(SRC_DIR)/scope.H
		$(SRC_DIR)/make.allocd < $(SRC_DIR)/scope.H > scope.h

node.h:		$(SRC_DIR)/make.allocd $(SRC_DIR)/node.H
		$(SRC_DIR)/make.allocd < $(SRC_DIR)/node.H > node.h

desig.h:	$(SRC_DIR)/make.allocd $(SRC_DIR)/desig.H
		$(SRC_DIR)/make.allocd < $(SRC_DIR)/desig.H > desig.h

tmpvar.c:	$(SRC_DIR)/make.allocd $(SRC_DIR)/tmpvar.C
		$(SRC_DIR)/make.allocd < $(SRC_DIR)/tmpvar.C > tmpvar.c

casestat.c:	$(SRC_DIR)/make.allocd $(SRC_DIR)/casestat.C
		$(SRC_DIR)/make.allocd < $(SRC_DIR)/casestat.C > casestat.c

next.c:		$(NEXTFILES) $(SRC_DIR)/make.next
		$(SRC_DIR)/make.next $(NEXTFILES) > next.c

char.c:		$(SRC_DIR)/char.tab
		$(TABGEN) -f$(SRC_DIR)/char.tab >char.c
