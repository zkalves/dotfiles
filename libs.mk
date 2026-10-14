# Build CLI tools from source into a user-writable prefix, for hosts without
# root access. Each package is tracked by a stamp file, so an interrupted run
# resumes instead of rebuilding everything.

PREFIX    ?= $(HOME)/usr/local
SRC_DIR   ?= $(HOME)/work/src/tmp
STAMP_DIR := $(SRC_DIR)/.stamps

HELP2MAN_URL := https://ftp.gnu.org/gnu/help2man/help2man-1.47.8.tar.xz
AUTOMAKE_URL := https://ftp.gnu.org/gnu/automake/automake-1.16.1.tar.gz
NCURSES_URL  := https://ftp.gnu.org/gnu/ncurses/ncurses-6.1.tar.gz
HTOP_URL     := https://hisham.hm/htop/releases/2.2.0/htop-2.2.0.tar.gz
LIBEVENT_URL := https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz
TMUX_GIT     := https://github.com/tmux/tmux.git
NEOVIM_GIT   := https://github.com/neovim/neovim.git

LIBS := help2man automake ncurses libevent htop tmux neovim

# Let each build find what the earlier ones installed.
export PATH            := $(PREFIX)/bin:$(PATH)
export PKG_CONFIG_PATH := $(PREFIX)/lib/pkgconfig:$(PKG_CONFIG_PATH)
export CPPFLAGS        := -I$(PREFIX)/include -I$(PREFIX)/include/ncurses
export LDFLAGS         := -L$(PREFIX)/lib

# $(1) source url, $(2) extracted directory, $(3) extra configure flags
define build_tarball
mkdir -p $(SRC_DIR) $(STAMP_DIR)
cd $(SRC_DIR) && { test -f $(notdir $(1)) || wget -q $(1); }
cd $(SRC_DIR) && rm -rf $(2) && tar xf $(notdir $(1))
cd $(SRC_DIR)/$(2) && ./configure --prefix=$(PREFIX) $(3)
$(MAKE) -C $(SRC_DIR)/$(2)
$(MAKE) -C $(SRC_DIR)/$(2) install
touch $@
endef

# $(1) git url, $(2) checkout directory
define clone_repo
mkdir -p $(SRC_DIR) $(STAMP_DIR)
test -d $(SRC_DIR)/$(2)/.git || git clone --recurse-submodules $(1) $(SRC_DIR)/$(2)
endef

.PHONY: libs libs-clean $(LIBS)

libs: $(addprefix $(STAMP_DIR)/,$(LIBS))

$(LIBS): %: $(STAMP_DIR)/%

$(STAMP_DIR)/help2man:
	$(call build_tarball,$(HELP2MAN_URL),help2man-1.47.8,)

$(STAMP_DIR)/automake: $(STAMP_DIR)/help2man
	$(call build_tarball,$(AUTOMAKE_URL),automake-1.16.1,)

$(STAMP_DIR)/ncurses:
	$(call build_tarball,$(NCURSES_URL),ncurses-6.1,)

$(STAMP_DIR)/libevent:
	$(call build_tarball,$(LIBEVENT_URL),libevent-2.1.8-stable,--disable-shared)

$(STAMP_DIR)/htop: $(STAMP_DIR)/ncurses
	$(call build_tarball,$(HTOP_URL),htop-2.2.0,)

$(STAMP_DIR)/tmux: $(STAMP_DIR)/libevent $(STAMP_DIR)/ncurses $(STAMP_DIR)/automake
	$(call clone_repo,$(TMUX_GIT),tmux)
	cd $(SRC_DIR)/tmux && sh autogen.sh
	cd $(SRC_DIR)/tmux && ./configure --prefix=$(PREFIX)
	$(MAKE) -C $(SRC_DIR)/tmux
	$(MAKE) -C $(SRC_DIR)/tmux install
	touch $@

$(STAMP_DIR)/neovim:
	$(call clone_repo,$(NEOVIM_GIT),neovim)
	$(MAKE) -C $(SRC_DIR)/neovim CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$(PREFIX)"
	$(MAKE) -C $(SRC_DIR)/neovim install
	touch $@

libs-clean:
	rm -rf $(STAMP_DIR)
