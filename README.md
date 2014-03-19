dpkg-sphinx-se
==============

Script that build debian package for percona-server sphinx-se plugin "ha_sphinx.so" with fpm.

## Usage:
```bash
bundle install
build.sh -s 2.1.6 -p 5.5.36-34.1 -d 5.5.36-rel34.1-642.wheezy -o my_org
```

You get your .deb in _pkg directory.


## Links:
* [Percona server](http://www.percona.com/)
* [Sphinxsearch](http://sphinxsearch.com/)
* [FPM](https://github.com/jordansissel/fpm)
