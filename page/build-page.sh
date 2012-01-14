#!/bin/bash

. ./build-common.sh

./build-index.sh

(
  cd $TOPDIR;
  rm -Rf $PKG
  mkdir -p $PKG/samples $PKG/out
  cp BUGS COPYING IDEAS README Makefile codecs.txt codecgraph{,.1,.py} $PKG/
  cp samples/*.txt $PKG/samples/
  tar cf - $PKG | gzip -c > htdocs/$PKG.tar.gz
  rm -Rf $PKG
  
  make svg
  rm -f htdocs/out/*
  cp out/*svg htdocs/out/
  cp out/*js htdocs/out/
)

