tar -cvf results1.tar results
gzip -c results1.tar >results1.tar.gz
mutt -s "Night Build Sanity Test InsideChamber " glu@actiontec.com -a /home/autolab2/mi424wr/results1.tar.gz < /home/autolab2/mi424wr/resulttext
mutt -s "Night Build Sanity Test InsideChamber" vkanchan@actiontec.com -a /home/autolab2/mi424wr/results1.tar.gz < /home/autolab2/mi424wr/resulttext
mutt -s "Night Build Sanity Test InsideChamber" bnoll@actiontec.com -a /home/autolab2/mi424wr/results1.tar.gz < /home/autolab2/mi424wr/resulttext
