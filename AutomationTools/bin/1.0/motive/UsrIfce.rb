# InternetGatewayDevice.UserInterface.
# InternetGatewayDevice.UserInterface.PasswordRequired

require 'motive'

class UsrIfce
    def initialize(motive)

        parameter = motive.setParameterValues

        parameter.at('InternetGatewayDevice.UserInterface')
        parameter.set('boolean', 'PasswordRequired', 'true')

        motive.parameterSubmit


        parameter = motive.getParameterValues

        parameter.at('InternetGatewayDevice.UserInterface')
        parameter.get('PasswordRequired')
        # parameter.get('PasswordUserSelectable')
        # parameter.get('UpgradAvailable')
        # parameter.get('WarrantyDate')
        # parameter.get('ISPName')
        # parameter.get('ISPHelpDesk')
        # parameter.get('ISPHomePage')
        # parameter.get('ISPLogo')
        # parameter.get('ISPLogoSize')
        # parameter.get('ISPMailServer')
        # parameter.get('ISPNewsServer')
        # parameter.get('TextColor')
        # parameter.get('BackgroundColor')
        # parameter.get('ButtonColor')
        # parameter.get('ButtonTextColor')
        # parameter.get('AutoUpdateServer')
        # parameter.get('UserUpdateServer')
        # parameter.get('ExampleLogin')
        # parameter.get('ExamplePassword')

        motive.parameterSubmit
    end
end
