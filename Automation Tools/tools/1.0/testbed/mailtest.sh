#!/bin/bash
perl $SQAROOT/bin/1.0/common/sshcli.pl  -d esxd001-pc1 -u root -p actiontec -v 'echo \"test sendmail\" | mutt -s \"test mail esxd001-pc1\" jonguyen@actiontec.com tzheng@actiontec.com'
perl $SQAROOT/bin/1.0/common/sshcli.pl  -d esxd001-pc3 -u root -p actiontec -v 'echo \"test sendmail\" | mutt -s \"test mail esxd001-pc3\" jonguyen@actiontec.com tzheng@actiontec.com'
perl $SQAROOT/bin/1.0/common/sshcli.pl  -d esxd001-pc5 -u root -p actiontec -v 'echo \"test sendmail\" | mutt -s \"test mail esxd001-pc5\" jonguyen@actiontec.com tzheng@actiontec.com'
perl $SQAROOT/bin/1.0/common/sshcli.pl  -d esxd001-pc7 -u root -p actiontec -v 'echo \"test sendmail\" | mutt -s \"test mail esxd001-pc7\" jonguyen@actiontec.com tzheng@actiontec.com'
perl $SQAROOT/bin/1.0/common/sshcli.pl  -d esxd001-pc9 -u root -p actiontec -v 'echo \"test sendmail\" | mutt -s \"test mail esxd001-pc9\" jonguyen@actiontec.com tzheng@actiontec.com'

perl $SQAROOT/bin/1.0/common/sshcli.pl  -d esxd003-pc1 -u root -p actiontec -v 'echo \"test sendmail\" | mutt -s \"test mail esxd003-pc1\" jonguyen@actiontec.com tzheng@actiontec.com'

perl $SQAROOT/bin/1.0/common/sshcli.pl  -d esxd003-pc3 -u root -p actiontec -v 'echo \"test sendmail\" | mutt -s \"test mail esxd003-pc3\" jonguyen@actiontec.com tzheng@actiontec.com'

perl $SQAROOT/bin/1.0/common/sshcli.pl  -d esxd003-pc5 -u root -p actiontec -v 'echo \"test sendmail\" | mutt -s \"test mail esxd003-pc5\" jonguyen@actiontec.com tzheng@actiontec.com'

perl $SQAROOT/bin/1.0/common/sshcli.pl  -d esxd003-pc7 -u root -p actiontec -v 'echo \"test sendmail\" | mutt -s \"test mail esxd003-pc7\" jonguyen@actiontec.com tzheng@actiontec.com'

perl $SQAROOT/bin/1.0/common/sshcli.pl  -d esxd003-pc9 -u root -p actiontec -v 'echo \"test sendmail\" | mutt -s \"test mail esxd003-pc9\" jonguyen@actiontec.com tzheng@actiontec.com'

perl $SQAROOT/bin/1.0/common/sshcli.pl  -d esxd003-pc11 -u root -p actiontec -v 'echo \"test sendmail\" | mutt -s \"test mail esxd003-pc11\" jonguyen@actiontec.com tzheng@actiontec.com'

