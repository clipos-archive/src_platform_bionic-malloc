CC ?= gcc

LIB := libbionic-malloc.so
MAJOR := 0
MINOR := 0
MICRO := 0
FULLVER := ${MAJOR}.${MINOR}.${MICRO}
LIB_FULLVER := ${LIB}.${FULLVER}


DEFINES := -DUSE_LOCKS -DFOOTERS -DUSE_DEV_RANDOM
LFLAGS := -Wl,-soname,${LIB}.${MAJOR}

ifdef MMAP_ONLY
DEFINES += -DHAVE_MORECORE=0
else
DEFINES += -DHAVE_MORECORE
endif

ifndef MALLINFO
DEFINES += -DNO_MALLINFO
endif

ifdef DEBUG
DEFINES += -DDEBUG
endif

CFLAGS ?= -O2 -Wall -Wextra

OBJS_DIR ?= obj

DEPS_DIR = ${OBJS_DIR}/.deps

all: build

${OBJS_DIR}:
	mkdir -p ${OBJS_DIR}

${DEPS_DIR}:
	mkdir -p ${DEPS_DIR}

${OBJS_DIR}/%.o:%.c Makefile
	$(CC) -fpic $(DEFINES) $(CFLAGS) $(IFLAGS) -MT $@ -MD -MP -MF ${DEPS_DIR}/$*.d -c -o $@ $<

build: ${OBJS_DIR} ${DEPS_DIR} ${LIB_FULLVER}

${LIB_FULLVER}: ${OBJS_DIR}/dlmalloc.o 
	$(CC) -shared $(CFLAGS) $(LFLAGS) -o $@ $^ $(LDFLAGS)
	ln -sf $@ ${LIB}
	ln -sf $@ ${LIB}.${MAJOR}

clean:
	rm -f ${LIB_FULLVER} ${LIB}.${MAJOR} ${LIB} 
	rm -fr ${OBJS_DIR}

-include ${DEPS_DIR}/dlmalloc.d
