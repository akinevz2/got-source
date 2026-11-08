# got-source — install the `get` shell function + the `got` script.
#
#   make install      install both files + hook the rc files
#   make uninstall    remove both files + strip the rc hooks
#   make check        smoke-test an installed tree
#
# Knobs:
#   PREFIX   install root (default $HOME/.local)
#   DESTDIR  staging prefix for packaged installs (prepended to PREFIX)
#   SKIP_RC=1   install files only, do not touch any rc files
#   RC_FILES="..."   explicit rc file list (default: existing ~/.bashrc
#                    and ~/.zshrc)
#
# The rc hook is a marker-delimited block (">>> got-source >>>") that
# sources get.sh into every new shell; it is appended only once and
# removed cleanly on uninstall.

PREFIX   ?= $(HOME)/.local
BINDIR   := $(DESTDIR)$(PREFIX)/bin
SHAREDIR := $(DESTDIR)$(PREFIX)/share/got
# The rc hook must reference the REAL (post-staging) path, so it is
# derived from PREFIX alone — DESTDIR is packaging scaffolding only.
GET_SH   := $(PREFIX)/share/got/get.sh

RC_FILES ?= $(wildcard $(HOME)/.bashrc $(HOME)/.zshrc)

.DEFAULT_GOAL := install
.PHONY: install install-bin install-rc uninstall uninstall-rc check

install: install-bin install-rc
	@echo "got-source: installed ($(BINDIR)/got, $(SHAREDIR)/get.sh)"

install-bin:
	@install -d "$(BINDIR)" "$(SHAREDIR)"
	@install -m 0755 got "$(BINDIR)/got"
	@install -m 0644 get.sh "$(SHAREDIR)/get.sh"

install-rc:
ifeq ($(SKIP_RC),)
	@for rc in $(RC_FILES); do \
		[ -f "$$rc" ] || continue; \
		if grep -qF '# >>> got-source >>>' "$$rc"; then \
			echo "got-source: rc hook already present in $$rc"; \
		else \
			{ printf '\n%s\n' '# >>> got-source >>>'; \
			  printf '%s\n' '# source the get() function (installed by got-source)'; \
			  printf '[ -f "%s" ] && . "%s"\n' "$(GET_SH)" "$(GET_SH)"; \
			  printf '%s\n' '# <<< got-source <<<'; } >> "$$rc"; \
			echo "got-source: hooked $$rc"; \
		fi; \
	done
endif

uninstall: uninstall-rc
	@rm -f "$(BINDIR)/got" "$(SHAREDIR)/get.sh"
	@rmdir -p "$(SHAREDIR)" 2>/dev/null || true
	@echo "got-source: uninstalled"

uninstall-rc:
	@for rc in $(RC_FILES); do \
		[ -f "$$rc" ] || continue; \
		tmp=$$(mktemp); \
		sed "\|^# >>> got-source >>>\$$|,\|^# <<< got-source <<<\$$|d" "$$rc" > "$$tmp" \
			&& cat "$$tmp" > "$$rc"; \
		rm -f "$$tmp"; \
	done

check:
	@"$(BINDIR)/got" --help >/dev/null && echo "got-source: got runs"
	@sh -c '. "$(SHAREDIR)/get.sh" && type get >/dev/null' \
		&& echo "got-source: get() sources"
	@if [ -z "$(DESTDIR)" ] && [ "$(SKIP_RC)" != 1 ]; then \
		for rc in $(RC_FILES); do \
			[ -f "$$rc" ] && grep -qF '# >>> got-source >>>' "$$rc" \
				&& echo "got-source: rc hook present in $$rc"; \
		done; \
	fi
