rbm=./rbm/rbm

all: release

release: submodule-update
	$(rbm) build ncdns --target release --target ncdns-all

release-android-armv7: submodule-update
	$(rbm) build ncdns --target release --target ncdns-android-armv7

release-android-x86: submodule-update
	$(rbm) build ncdns --target release --target ncdns-android-x86

release-linux-x86_64: submodule-update
	$(rbm) build ncdns --target release --target ncdns-linux-x86_64

release-linux-i686: submodule-update
	$(rbm) build ncdns --target release --target ncdns-linux-i686

release-windows-i686: submodule-update
	$(rbm) build ncdns --target release --target ncdns-windows-i686

release-windows-x86_64: submodule-update
	$(rbm) build ncdns --target release --target ncdns-windows-x86_64

release-osx-x86_64: submodule-update
	$(rbm) build ncdns --target release --target ncdns-osx-x86_64

submodule-update:
	git submodule update --init
	$(MAKE) -C tor-browser-build submodule-update

fetch: submodule-update
	$(rbm) fetch

clean: submodule-update
	./tools/clean-old

clean-dry-run: submodule-update
	./tools/clean-old --dry-run

