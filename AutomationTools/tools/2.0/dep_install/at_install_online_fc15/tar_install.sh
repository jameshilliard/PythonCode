#/bin/bash

#
tar -zxvvf  httplib2-0.6.0-autotest.tar.gz
cd httplib2-0.6.0
python setup.py install
cd -
rm -rf httplib2-0.6.0

# install Log4perl
tar -zxvvf Log-Log4perl-1.21.tar.gz 
cd Log-Log4perl-1.21
perl Makefile.PL 
make 
make test
make install
cd -
rm -rf Log-Log4perl-1.21

# install vim plugins
tar -zxvvf vim.tar.gz
mv vim  ~/.vim
cp -rf ~/.vim/vimrc ~/.vimrc
