# ncdns-repro

ncdns reproducible build harnesses for RBM.

## Build instructions

First, initialize the stuff that's derived from upstream Tor:

~~~
./tools/setup-submodule-symlinks.sh
./tools/patch-tor-to-namecoin.sh
~~~

Then follow the Tor documentation to build via the Makefile.

## License

MIT License.
