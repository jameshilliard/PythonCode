# InternetGatewayDevice.Time.
# InternetGatewayDevice.Time.NTPServer1
# InternetGatewayDevice.Time.NTPServer2
# InternetGatewayDevice.Time.NTPServer3
# InternetGatewayDevice.Time.CurrentLocalTime
# InternetGatewayDevice.Time.LocalTimeZone
# InternetGatewayDevice.Time.LocalTimeZoneName
# InternetGatewayDevice.Time.DaylightSavingsUsed
# InternetGatewayDevice.Time.DaylightSavingsStart
# InternetGatewayDevice.Time.DaylightSavingsEnd

require 'motive'

class Tm
    def initialize(motive)

        parameter = motive.setParameterValues

        parameter.at('InternetGatewayDevice.Time')
        parameter.set('string', 'NTPServer1', 'ntp.actiontec.com')
        parameter.set('string', 'NTPServer2', '')
        parameter.set('string', 'NTPServer3', '')
        parameter.set('string', 'LocalTimeZone', '-05:00')
        parameter.set('string', 'LocalTimeZoneName', 'Eastern_Time')
        parameter.set('boolean', 'DaylightSavingsUsed', 'true')

        motive.parameterSubmit


        parameter = motive.getParameterValues

        parameter.at('InternetGatewayDevice.Time')
        parameter.get('NTPServer1')
        parameter.get('NTPServer2')
        parameter.get('NTPServer3')
        parameter.get('CurrentLocalTime')
        parameter.get('LocalTimeZone')
        parameter.get('LocalTimeZoneName')
        parameter.get('DaylightSavingsUsed')
        parameter.get('DaylightSavingsStart')
        parameter.get('DaylightSavingsEnd')

        motive.parameterSubmit
    end
end
