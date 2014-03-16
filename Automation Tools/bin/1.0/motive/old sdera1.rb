require 'motive'

$username = 'ps_training'
$password = 'celab123'
$serial = 'CSJE8311800055'

class DeviceRecovery
    MINUTES = 60
    SHORT = 0
    LONG = 1
    def wait(duration)
        puts 'Waiting for device recovery ...'
        if duration == SHORT
            waitTime = 30
        else
            waitTime = 2.5 * MINUTES
        end
        sleep waitTime
    end
end


begin
    motive = Motive.new($username, $password)
    motive.selectDevice($serial)
    deviceRecovery = DeviceRecovery.new

    parameter = motive.setParameterValues
    parameter.at('InternetGatewayDevice.X_ACTIONTEC.SDERA')
    parameter.set('boolean', 'Enable', 'true')
    parameter.set('boolean', 'ScheduleOption', 'false')
    motive.parameterSubmit

    puts '----- Case of ( MoCA Ether WIFI ) = ( off, off, off ) -----'
    parameter = motive.setParameterValues
    parameter.at('InternetGatewayDevice.LANDevice.1.WLANConfiguration.7')
    parameter.set('boolean', 'Enable', 'false')
    parameter.at('InternetGatewayDevice.LANDevice.1.LANEthernetInterfaceConfig.2')
    parameter.set('boolean', 'Enable', 'false')
    parameter.at('InternetGatewayDevice.LANDevice.1.LANMoCAInterfaceConfig.4')
    parameter.set('boolean', 'Enabled', 'false')
    motive.parameterSubmit
    deviceRecovery.wait(DeviceRecovery::LONG)

    parameter = motive.getParameterValues
    parameter.at('InternetGatewayDevice.X_ACTIONTEC.SDERA.Result')
    parameter.get('TestCase.')
    motive.parameterSubmit

    verification = motive.verifyParameterValues
    verification.at('InternetGatewayDevice.X_ACTIONTEC.SDERA.Result.TestCase.8')
    verification.verify('Log','TLANTYPE=LMOCA=F,LETH=F,LWIFI=F')

    puts '----- Case of ( MoCA Ether WIFI ) = ( off, off, on ) -----'
    parameter = motive.setParameterValues
    parameter.at('InternetGatewayDevice.LANDevice.1.WLANConfiguration.7')
    parameter.set('boolean', 'Enable', 'true')
    parameter.at('InternetGatewayDevice.LANDevice.1.LANEthernetInterfaceConfig.2')
    parameter.set('boolean', 'Enable', 'false')
    parameter.at('InternetGatewayDevice.LANDevice.1.LANMoCAInterfaceConfig.4')
    parameter.set('boolean', 'Enabled', 'false')
    motive.parameterSubmit
    deviceRecovery.wait(DeviceRecovery::SHORT)

    parameter = motive.getParameterValues
    parameter.at('InternetGatewayDevice.X_ACTIONTEC.SDERA.Result')
    parameter.get('TestCase.')
    motive.parameterSubmit

    verification.at('InternetGatewayDevice.X_ACTIONTEC.SDERA.Result.TestCase.8')
    verification.verify('Log','TLANTYPE=LMOCA=F,LETH=F,LWIFI=T')

    puts '----- Case of ( MoCA Ether WIFI ) = ( off, on, off ) -----'
    parameter = motive.setParameterValues
    parameter.at('InternetGatewayDevice.LANDevice.1.WLANConfiguration.7')
    parameter.set('boolean', 'Enable', 'false')
    parameter.at('InternetGatewayDevice.LANDevice.1.LANEthernetInterfaceConfig.2')
    parameter.set('boolean', 'Enable', 'true')
    parameter.at('InternetGatewayDevice.LANDevice.1.LANMoCAInterfaceConfig.4')
    parameter.set('boolean', 'Enabled', 'false')
    motive.parameterSubmit
    deviceRecovery.wait(DeviceRecovery::SHORT)

    parameter = motive.getParameterValues
    parameter.at('InternetGatewayDevice.X_ACTIONTEC.SDERA.Result')
    parameter.get('TestCase.')
    motive.parameterSubmit

    verification.at('InternetGatewayDevice.X_ACTIONTEC.SDERA.Result.TestCase.8')
    verification.verify('Log','TLANTYPE=LMOCA=F,LETH=T,LWIFI=F')

    puts '----- Case of ( MoCA Ether WIFI ) = ( off, on, on ) -----'
    parameter = motive.setParameterValues
    parameter.at('InternetGatewayDevice.LANDevice.1.WLANConfiguration.7')
    parameter.set('boolean', 'Enable', 'true')
    parameter.at('InternetGatewayDevice.LANDevice.1.LANEthernetInterfaceConfig.2')
    parameter.set('boolean', 'Enable', 'true')
    parameter.at('InternetGatewayDevice.LANDevice.1.LANMoCAInterfaceConfig.4')
    parameter.set('boolean', 'Enabled', 'false')
    motive.parameterSubmit
    deviceRecovery.wait(DeviceRecovery::SHORT)

    parameter = motive.getParameterValues
    parameter.at('InternetGatewayDevice.X_ACTIONTEC.SDERA.Result')
    parameter.get('TestCase.')
    motive.parameterSubmit

    verification.at('InternetGatewayDevice.X_ACTIONTEC.SDERA.Result.TestCase.8')
    verification.verify('Log','TLANTYPE=LMOCA=F,LETH=T,LWIFI=T')

    puts '----- Case of ( MoCA Ether WIFI ) = ( on, off, off ) -----'
    parameter = motive.setParameterValues
    parameter.at('InternetGatewayDevice.LANDevice.1.WLANConfiguration.7')
    parameter.set('boolean', 'Enable', 'false')
    parameter.at('InternetGatewayDevice.LANDevice.1.LANEthernetInterfaceConfig.2')
    parameter.set('boolean', 'Enable', 'false')
    parameter.at('InternetGatewayDevice.LANDevice.1.LANMoCAInterfaceConfig.4')
    parameter.set('boolean', 'Enabled', 'true')
    motive.parameterSubmit
    deviceRecovery.wait(DeviceRecovery::LONG)

    parameter = motive.getParameterValues
    parameter.at('InternetGatewayDevice.X_ACTIONTEC.SDERA.Result')
    parameter.get('TestCase.')
    motive.parameterSubmit

    verification.at('InternetGatewayDevice.X_ACTIONTEC.SDERA.Result.TestCase.8')
    verification.verify('Log','TLANTYPE=LMOCA=T,LETH=F,LWIFI=F')

    puts '----- Case of ( MoCA Ether WIFI ) = ( on, off, on ) -----'
    parameter = motive.setParameterValues
    parameter.at('InternetGatewayDevice.LANDevice.1.WLANConfiguration.7')
    parameter.set('boolean', 'Enable', 'true')
    parameter.at('InternetGatewayDevice.LANDevice.1.LANEthernetInterfaceConfig.2')
    parameter.set('boolean', 'Enable', 'false')
    parameter.at('InternetGatewayDevice.LANDevice.1.LANMoCAInterfaceConfig.4')
    parameter.set('boolean', 'Enabled', 'true')
    motive.parameterSubmit
    deviceRecovery.wait(DeviceRecovery::SHORT)

    parameter = motive.getParameterValues
    parameter.at('InternetGatewayDevice.X_ACTIONTEC.SDERA.Result')
    parameter.get('TestCase.')
    motive.parameterSubmit

    verification.at('InternetGatewayDevice.X_ACTIONTEC.SDERA.Result.TestCase.8')
    verification.verify('Log','TLANTYPE=LMOCA=T,LETH=F,LWIFI=T')

    puts '----- Case of ( MoCA Ether WIFI ) = ( on, on, off ) -----'
    parameter = motive.setParameterValues
    parameter.at('InternetGatewayDevice.LANDevice.1.WLANConfiguration.7')
    parameter.set('boolean', 'Enable', 'false')
    parameter.at('InternetGatewayDevice.LANDevice.1.LANEthernetInterfaceConfig.2')
    parameter.set('boolean', 'Enable', 'true')
    parameter.at('InternetGatewayDevice.LANDevice.1.LANMoCAInterfaceConfig.4')
    parameter.set('boolean', 'Enabled', 'true')
    motive.parameterSubmit
    deviceRecovery.wait(DeviceRecovery::SHORT)

    parameter = motive.getParameterValues
    parameter.at('InternetGatewayDevice.X_ACTIONTEC.SDERA.Result')
    parameter.get('TestCase.')
    motive.parameterSubmit

    verification.at('InternetGatewayDevice.X_ACTIONTEC.SDERA.Result.TestCase.8')
    verification.verify('Log','TLANTYPE=LMOCA=T,LETH=T,LWIFI=F')

    puts '----- Case of ( MoCA Ether WIFI ) = ( on, on, on ) -----'
    parameter = motive.setParameterValues
    parameter.at('InternetGatewayDevice.LANDevice.1.WLANConfiguration.7')
    parameter.set('boolean', 'Enable', 'true')
    parameter.at('InternetGatewayDevice.LANDevice.1.LANEthernetInterfaceConfig.2')
    parameter.set('boolean', 'Enable', 'true')
    parameter.at('InternetGatewayDevice.LANDevice.1.LANMoCAInterfaceConfig.4')
    parameter.set('boolean', 'Enabled', 'true')
    motive.parameterSubmit
    deviceRecovery.wait(DeviceRecovery::SHORT)

    parameter = motive.getParameterValues
    parameter.at('InternetGatewayDevice.X_ACTIONTEC.SDERA.Result')
    parameter.get('TestCase.')
    motive.parameterSubmit

    verification.at('InternetGatewayDevice.X_ACTIONTEC.SDERA.Result.TestCase.8')
    verification.verify('Log','TLANTYPE=LMOCA=T,LETH=T,LWIFI=T')

    motive.shutdown
end
