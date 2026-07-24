# Portable build + install for FritzCallMonitor (Neutrino plugin, compiled
# binary). This Makefile is the single source of build truth: the generic PC
# builder and the OE recipe both call `all` + `install` and pass the toolchain
# vars plus destination knobs below. No build logic lives outside this file.
#
# The legacy Makefile.am is kept for reference only; it is not the build path.

PROGRAM := FritzCallMonitor

# --- Toolchain (overridable) ------------------------------------------------
CXX        ?= g++
PKG_CONFIG ?= pkg-config

# --- Destination knobs (overridable; native /usr defaults) ------------------
DESTDIR   ?=
PREFIX    ?= /usr
BINDIR    ?= $(PREFIX)/bin
CONFIGDIR ?= /var/tuxbox/config
ICONSDIR  ?= $(PREFIX)/share/tuxbox/neutrino/plugins
INITDIR   ?= /etc/init.d
# Installed name of the init script. Defaults to the Makefile.am intent; the
# generic PC builder overrides this to keep its historical "fritzcallmonitor.init".
INIT_NAME ?= fritzcallmonitor

# --- Build knobs ------------------------------------------------------------
OBJDIR   ?= $(CURDIR)/.build
CPPFLAGS ?=
CXXFLAGS ?= -O2
LDFLAGS  ?=

PKG_CFLAGS := $(shell $(PKG_CONFIG) --cflags freetype2 libcurl 2>/dev/null)
PKG_LIBS   := $(shell $(PKG_CONFIG) --libs freetype2 libcurl 2>/dev/null)

ALL_CPPFLAGS := $(CPPFLAGS) -I$(CURDIR) $(PKG_CFLAGS)
ALL_LIBS     := $(PKG_LIBS) -lcrypto -lssl -lpthread

SOURCES := connect.cpp FritzCallMonitor.cpp
OBJS    := $(addprefix $(OBJDIR)/,$(SOURCES:.cpp=.o))
BIN     := $(OBJDIR)/$(PROGRAM)

.PHONY: all install uninstall clean

all: $(BIN)

$(OBJDIR)/%.o: %.cpp
	@mkdir -p $(OBJDIR)
	$(CXX) $(ALL_CPPFLAGS) $(CXXFLAGS) -c -o $@ $<

$(BIN): $(OBJS)
	$(CXX) -o $@ $(OBJS) $(LDFLAGS) $(ALL_LIBS)

install: all
	install -d "$(DESTDIR)$(BINDIR)" "$(DESTDIR)$(CONFIGDIR)" "$(DESTDIR)$(ICONSDIR)" "$(DESTDIR)$(INITDIR)"
	install -m 0755 "$(BIN)" "$(DESTDIR)$(BINDIR)/$(PROGRAM)"
	install -m 0644 FritzCallMonitor.cfg "$(DESTDIR)$(CONFIGDIR)/"
	install -m 0644 FritzCallMonitor.addr "$(DESTDIR)$(CONFIGDIR)/"
	install -m 0644 hint_FritzCallMonitor.png "$(DESTDIR)$(ICONSDIR)/"
	install -m 0755 fritzcallmonitor.init "$(DESTDIR)$(INITDIR)/$(INIT_NAME)"

uninstall:
	rm -f "$(DESTDIR)$(BINDIR)/$(PROGRAM)"
	rm -f "$(DESTDIR)$(CONFIGDIR)/FritzCallMonitor.cfg"
	rm -f "$(DESTDIR)$(CONFIGDIR)/FritzCallMonitor.addr"
	rm -f "$(DESTDIR)$(ICONSDIR)/hint_FritzCallMonitor.png"
	rm -f "$(DESTDIR)$(INITDIR)/$(INIT_NAME)"

clean:
	rm -rf $(OBJDIR)
