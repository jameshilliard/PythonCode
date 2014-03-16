# InternetGatewayDevice.QueueManagement.
# InternetGatewayDevice.QueueManagement.Enable
# InternetGatewayDevice.QueueManagement.MaxQueues
# InternetGatewayDevice.QueueManagement.MaxClassificationEntries
# InternetGatewayDevice.QueueManagement.ClassificationNumberOfEntries
# InternetGatewayDevice.QueueManagement.MaxPolicerEntries
# InternetGatewayDevice.QueueManagement.MaxQueueEntries
# InternetGatewayDevice.QueueManagement.QueueNumberOfEntries
# InternetGatewayDevice.QueueManagement.DefaultPolicer
# InternetGatewayDevice.QueueManagement.DefaultQueue
# InternetGatewayDevice.QueueManagement.DefaultDSCPMark

require 'motive'

class QMgmt
    def initialize(motive)

        parameter = motive.setParameterValues

        parameter.at('InternetGatewayDevice.QueueManagement')
        parameter.set('boolean', 'Enable', 'true')
        parameter.set('unsignedInt', 'MaxQueues', '8192')
        parameter.set('unsignedInt', 'MaxClassificationEntries', '1024')
        parameter.set('unsignedInt', 'ClassificationNumberOfEntries', '0')
        parameter.set('unsignedInt', 'MaxPolicerEntries', '1024')
        parameter.set('unsignedInt', 'MaxQueueEntries', '0')
        parameter.set('unsignedInt', 'QueueNumberOfEntries', '0')
        parameter.set('int', 'DefaultPolicer', '-1')
        parameter.set('unsignedInt', 'DefaultQueue', '0')
        parameter.set('int', 'DefaultDSCPMark', '-1')

        motive.parameterSubmit


        parameter = motive.getParameterValues

        parameter.at('InternetGatewayDevice.QueueManagement')
        parameter.get('Enable')
        parameter.get('MaxQueues')
        parameter.get('MaxClassificationEntries')
        parameter.get('ClassificationNumberOfEntries')
        parameter.get('MaxPolicerEntries')
        parameter.get('MaxQueueEntries')
        parameter.get('QueueNumberOfEntries')
        parameter.get('DefaultPolicer')
        parameter.get('DefaultQueue')
        parameter.get('DefaultDSCPMark')

        motive.parameterSubmit


        parameter = motive.verifyParameterValues

        parameter.at('InternetGatewayDevice.QueueManagement')
        parameter.verify('Enable', 'true')
        parameter.verify('MaxQueues', '8192')
        parameter.verify('MaxClassificationEntries', '1024')
        parameter.verify('ClassificationNumberOfEntries', '0')
        parameter.verify('MaxPolicerEntries', '1024')
        parameter.verify('MaxQueueEntries', '0')
        parameter.verify('QueueNumberOfEntries', '0')
        parameter.verify('DefaultPolicer', '-1')
        parameter.verify('DefaultQueue', '0')
        parameter.verify('DefaultDSCPMark', '-1')
    end
end
