# Paths
LUASCRIPT = bundle.lua
BINARY = synch
LUAJIT_LIB = /data/data/com.termux/files/usr/lib/libluajit-5.1.a
LUAJIT_INC = /data/data/com.termux/files/usr/include/luajit-2.1

# Tools
LUA = luajit
LUASTATIC = luastatic

all: $(BINARY)

$(LUASCRIPT): synch.lua modules/*.lua utils/*.lua
	$(LUA) scripts/build.lua

$(BINARY): $(LUASCRIPT)
	$(LUASTATIC) $(LUASCRIPT) $(LUAJIT_LIB) -I $(LUAJIT_INC) -lm -ldl -o $(BINARY)
	rm -f $(LUASCRIPT) bundle.luastatic.c bundle.luastatic.o

clean:
	rm -f $(LUASCRIPT) $(BINARY) bundle.luastatic.c bundle.luastatic.o

.PHONY: all clean
