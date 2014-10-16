$username = 'ps_training'
$password = 'celab123'
#$serial = 'CSJE8331700280'
$serial = '222'

$firmware = '20.8.12'
$size = '0000'

def run
    yield
end

def nop
end

require 'motive'
require 'Wan'
require 'Lan'
require 'Wlan'
require 'UsrIfce'
require 'Led'
require 'Tm'
require 'QMgmt'
require 'RmteAdm'
require 'MgmtSvr'
require 'PrtMps'
require 'Sdera'

begin
    motive = Motive.new($username, $password)

    ### { motive.getConfiguration }

    ### { motive.setFirmware($firmware, $size) }

    motive.selectDevice($serial)

    ### { motive.upgradeFirmware }

    ### { motive.upload('1 Vendor Configuration File', 'base') }

    ### { Wan.new(motive) }
    run { Lan.new(motive) }
    ### { Wlan.new(motive) }
    ### { UsrIfce.new(motive) }
    ### { Led.new(motive) }
    ### { Tm.new(motive) }
    ### { QMgmt.new(motive) }
    ### { RmteAdm.new(motive) }
    ### { MgmtSvr.new(motive) }
    ### { PrtMps.new(motive) }
    ### { Sdera.new(motive) }

    motive.shutdown
end
