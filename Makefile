RBM=./rbm/rbm

all: release

release:
	$(RBM) build ncdns --target ncdns-linux-x86_64

submodule-update:
	git submodule update --init

fetch: submodule-update
	$(RBM) fetch
