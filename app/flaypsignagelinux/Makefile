APP_NAME := flaypsignagelinux
PREFIX ?= /usr/local
SYSCONFDIR ?= /etc
SYSTEMD_DIR ?= $(SYSCONFDIR)/systemd/system
ICON_DIR ?= $(PREFIX)/share/pixmaps
APPLICATIONS_DIR ?= $(PREFIX)/share/applications

.PHONY: build release check test install install-assets install-service binding clean

build:
	cargo build

release:
	cargo build --release

check:
	cargo check --locked

test:
	cargo test --all-targets

install: release install-assets install-service
	install -Dm755 target/release/$(APP_NAME) $(DESTDIR)$(PREFIX)/bin/$(APP_NAME)

install-assets:
	install -Dm644 $(APP_NAME).desktop $(DESTDIR)$(APPLICATIONS_DIR)/$(APP_NAME).desktop
	install -Dm644 assets/$(APP_NAME).png $(DESTDIR)$(ICON_DIR)/$(APP_NAME).png

install-service:
	install -Dm644 packaging/systemd/$(APP_NAME).service $(DESTDIR)$(SYSTEMD_DIR)/$(APP_NAME).service

binding:
	bindgen --output src/qt_binding.rs --allowlist-file gui/lib.h gui/lib.h -- -xc++

clean:
	cargo clean
