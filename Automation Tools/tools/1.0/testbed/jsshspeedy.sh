#!/bin/sh
yum -y install mercurial
yum -y install autoconf213
yum -y install wireless-tools*
yum -y install libnotify*
#hg clone http://hg.mozilla.org/releases/mozilla-1.9.1/ /usr/local/191src
hg clone http://hg.mozilla.org/releases/mozilla-1.9.2/ /usr/local/192src
cd /usr/local/192src
echo "mk_add_options MOZ_CO_PROJECT=browser" >> .mozconfig
echo "mk_add_options MOZ_OBJDIR=@TOPSRCDIR@/firefox-jssh" >> .mozconfig
echo "ac_add_options --enable-extensions=default,jssh" >>.mozconfig
echo "ac_add_options --enable-application=browser" >> .mozconfig
make -f client.mk build
mv `which firefox` `which firefox`-old
cd ..
echo "----------------------------------------------"
echo " If you see the build failed, please see http://code.google.com/p/google-breakpad/issues/detail?id=305"
echo "----------------------------------------------"
#http://code.google.com/p/google-breakpad/issues/detail?id=305
#mv 191src/ /usr/local/
ln -s /usr/local/192src/firefox-jssh/dist/bin/firefox /usr/bin/firefox
#create a firefox profile 
killall firefox
echo " Make sure enter automation as profile manager"
#firefox --install-global-extension jssh-20081108-Linux.xpi
