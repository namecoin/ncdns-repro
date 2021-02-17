rbm=./rbm/rbm

all: release

# TODO: Replace the Makefile-based metatarget with an rbm-based one.
release: submodule-update release-linux-x86_64 release-linux-i686 release-windows-x86_64 release-windows-i686 release-osx-x86_64
	#$(rbm) build plain-binaries --target release --target ncdns-all

release-android-armv7: submodule-update
	$(rbm) build plain-binaries --target release --target ncdns-android-armv7

release-android-x86: submodule-update
	$(rbm) build plain-binaries --target release --target ncdns-android-x86

release-android-x86_64: submodule-update
	$(rbm) build plain-binaries --target release --target ncdns-android-x86_64

release-android-aarch64: submodule-update
	$(rbm) build plain-binaries --target release --target ncdns-android-aarch64

release-linux-x86_64: submodule-update
	$(rbm) build certdehydrate-dane-rest-api --target release --target ncdns-linux-x86_64
	$(rbm) build dnssec-hsts --target release --target ncdns-linux-x86_64
	$(rbm) build dnssec-hsts-native --target release --target ncdns-linux-x86_64
	$(rbm) build plain-binaries --target release --target ncdns-linux-x86_64

release-linux-i686: submodule-update
	$(rbm) build certdehydrate-dane-rest-api --target release --target ncdns-linux-i686
	$(rbm) build dnssec-hsts --target release --target ncdns-linux-i686
	$(rbm) build dnssec-hsts-native --target release --target ncdns-linux-i686
	$(rbm) build plain-binaries --target release --target ncdns-linux-i686

release-windows-i686: submodule-update
	$(rbm) build certdehydrate-dane-rest-api --target release --target ncdns-windows-i686
	$(rbm) build dnssec-hsts --target release --target ncdns-windows-i686
	$(rbm) build dnssec-hsts-native --target release --target ncdns-windows-i686
	$(rbm) build plain-binaries --target release --target ncdns-windows-i686

release-windows-x86_64: submodule-update
	$(rbm) build certdehydrate-dane-rest-api --target release --target ncdns-windows-x86_64
	$(rbm) build dnssec-hsts --target release --target ncdns-windows-x86_64
	$(rbm) build dnssec-hsts-native --target release --target ncdns-windows-x86_64
	$(rbm) build plain-binaries --target release --target ncdns-windows-x86_64

release-osx-x86_64: submodule-update
	$(rbm) build certdehydrate-dane-rest-api --target release --target ncdns-osx-x86_64
	$(rbm) build dnssec-hsts --target release --target ncdns-osx-x86_64
	$(rbm) build dnssec-hsts-native --target release --target ncdns-osx-x86_64
	$(rbm) build plain-binaries --target release --target ncdns-osx-x86_64

submodule-update:
	./setup-submodule-symlinks

fetch: submodule-update
	$(rbm) fetch

clean: submodule-update
	./tools/clean-old

clean-dry-run: submodule-update
	./tools/clean-old --dry-run

