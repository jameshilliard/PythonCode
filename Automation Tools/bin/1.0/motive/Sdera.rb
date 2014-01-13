require 'motive'

class Sdera
    def initialize(motive)

        parameter = motive.getParameterValues

        parameter.at('InternetGatewayDevice.X_ACTIONTEC.SDERA.Result.TestCase.1')
        parameter.get('Name')
        parameter.get('Log')

        motive.parameterSubmit
    end
end
