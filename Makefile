# Paths
LUASCRIPT = bundle.lua
BINARY = synch

LUAJIT_LIB = $(shell pkg-config --variable=libdir luajit | xargs -I{} echo {}/libluajit-5.1.a)
LUAJIT_INC = $(shell pkg-config --cflags-only-I luajit | sed 's/-I//')

# Installation
PREFIX ?= /usr/local
BINDIR = $(PREFIX)/bin

# Tools
LUA = luajit
LUASTATIC = luastatic
INSTALL = install

all: $(BINARY)

$(LUASCRIPT): synch.lua modules/*.lua utils/*.lua
	$(LUA) scripts/build.lua

$(BINARY): $(LUASCRIPT)
	$(LUASTATIC) $(LUASCRIPT) $(LUAJIT_LIB) -I $(LUAJIT_INC) -lm -ldl -o $(BINARY)
	rm -f $(LUASCRIPT) bundle.luastatic.c bundle.luastatic.o

install: $(BINARY)
	$(INSTALL) -d $(DESTDIR)$(BINDIR)
	$(INSTALL) -m 755 $(BINARY) $(DESTDIR)$(BINDIR)/$(BINARY)

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(BINARY)

clean:
	rm -f $(LUASCRIPT) $(BINARY) bundle.luastatic.c bundle.luastatic.o

.PHONY: all clean install uninstall
