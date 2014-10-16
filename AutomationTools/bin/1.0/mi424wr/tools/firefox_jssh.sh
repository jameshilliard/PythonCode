#!/bin/bash
yum install autoconf213
yum install mercurial
hg clone http://hg.mozilla.org/releases/mozilla-1.9.1/ 191src
cd 191src
echo "mk_add_options MOZ_CO_PROJECT=browser" >> .mozconfig
echo "mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/firefox-jssh" >> .mozconfig
echo "ac_add_options --enable-extensions=default,jssh" >>.mozconfig
echo "ac_add_options --enable-application=browser" >> .mozconfig
make -f client.mk build
./191src/firefox-jssh/dist/bin/firefox -jssh
