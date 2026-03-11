APPNAME     := dear
PREFIX      ?= /usr/local

BINDIR      := $(PREFIX)/bin
LIBDIR      := $(PREFIX)/lib/$(APPNAME)
COMPDIR     := $(PREFIX)/share/bash-completion/completions

BIN_SRC     := bin/$(APPNAME)
LIB_SRC     := $(wildcard lib/*.sh)
COMP_SRC    := bash-completion/$(APPNAME)

INSTALL     := install
INSTALL_BIN := $(INSTALL) -m 755
INSTALL_LIB := $(INSTALL) -m 644

.PHONY: all install uninstall

all:
	@echo "Nothing to build."

install:
	$(INSTALL) -d $(DESTDIR)$(BINDIR)
	$(INSTALL) -d $(DESTDIR)$(LIBDIR)
	$(INSTALL) -d $(DESTDIR)$(COMPDIR)

	$(INSTALL_BIN) $(BIN_SRC) $(DESTDIR)$(BINDIR)
	$(INSTALL_LIB) $(LIB_SRC) $(DESTDIR)$(LIBDIR)

	$(INSTALL_LIB) $(COMP_SRC) $(DESTDIR)$(COMPDIR)/$(APPNAME)

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(APPNAME)
	rm -f $(DESTDIR)$(LIBDIR)/*.sh
	rm -rf $(DESTDIR)$(LIBDIR)
	rm -f $(DESTDIR)$(COMPDIR)/$(APPNAME)

