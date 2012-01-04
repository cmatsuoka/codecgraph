TOPDIR=..
NAME=codecgraph
VERSION=`git log -1 --pretty=format:%ci|cut -f1 -d' '|sed 's!-!!g'`
PKG=$NAME-$VERSION
