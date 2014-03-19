dpkg-sphinx-se
==============

Script that compile and build debian package for percona-server sphinx-se plugin "ha_sphinx.so" with fpm.

## Who is who
* `scripts/postinst` - script for debian package that use after install new package. It register plugin in percona-server.
* `scripts/prerm` - script for debian package that use before purge package. Remove plugin from percona server.
* `build.sh` - main script: download, compile and pack to .deb.

## Options build.sh
* `-s` - version of sphinxsearch
* `-p` - version of percona server
* `-d` - version of percona server in Debian repo
* `-o` - optional. Used for mark iteration of package (example: wheezy1, myorg2, etc)

## Usage
```bash
bundle install
build.sh -s 2.1.6 -p 5.5.36-34.1 -d 5.5.36-rel34.1-642.wheezy -o my_org
```

You'll get your .deb in _pkg directory.


## Links
* [Percona server](http://www.percona.com/)
* [Sphinxsearch](http://sphinxsearch.com/)
* [FPM](https://github.com/jordansissel/fpm)
