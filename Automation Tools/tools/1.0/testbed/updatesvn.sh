cd ~
rm -rf ~/junk
mkdir ~/junk
cd ~/junk 
svn co svn://svn/svnroot/QA/automation
rm -f automation/config/1.0/common/tbprofile.xml
perl automation/bin/1.0/common/update_nosvn.pl -n -s automation -d update -l ~/junk
tar -cv update > update.tar
scp update.tar gfupdate@ceasy:~/.
perl automation/bin/1.0/common/clicfg.pl  -d $1 -i 22  -f automation/tools/1.0/tbsetup/update_remote.txt -u gfupdate -p gomtt03 -m "gfupdate*" -o 1000 

