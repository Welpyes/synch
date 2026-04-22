# Paths
LUASCRIPT = bundle.lua
BINARY = synch
LUAJIT_LIB = /data/data/com.termux/files/usr/lib/libluajit-5.1.a
LUAJIT_INC = /data/data/com.termux/files/usr/include/luajit-2.1

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
