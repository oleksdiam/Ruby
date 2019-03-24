#!/usr/bin/env ruby
require 'bundler/setup'
require 'cloudformation-ruby-dsl/cfntemplate'
require 'cloudformation-ruby-dsl/table'

tmpl = template do
  @stack_name = 'alb-testbench'

#   metadata 'AWS::CloudFormation::Interface', {
#     :ParameterGroups => [
#       {
#         :Label => { :default => 'Instance options' },
#         :Parameters => [ 'InstanceType', 'ImageId', 'KeyPairName' ]
#       },
#       {
#         :Label => { :default => 'Region & VPC options' },
#         :Parameters => [ 'Region', 'Environment', 'VpcId', 'Quantity' ]
#       },
#       {
#         :Label => { :default => 'Other options' },
#         :Parameters => [ 'Label', 'EmailAddress' ]
#       }
#     ],
#     :ParameterLabels => {
#       :EmailAddress => {
#         :default => "We value your privacy!"
#       }
#     }
#   }
  
  parameter 'Label',
            :Description => 'The label to apply to the stack instances.',
            :Type => 'String',
            :Default => 'cfnrdsl'
            # :UsePreviousValue => true

  parameter 'InstanceType',
            :Description => 'EC2 instance type',
            :Type => 'String',
            :Default => 't2.micro',
            :AllowedValues => %w(t1.micro t2.micro m1.small m1.medium m1.large m1.xlarge m2.xlarge m2.2xlarge m2.4xlarge c1.medium c1.xlarge),
            :ConstraintDescription => 'Must be a valid EC2 instance type.'

  parameter 'ImageId',
            :Description => 'EC2 Image ID',
            :Type => 'String',
            :Default => 'ami-02bcbb802e03574ba',
            :AllowedPattern => 'ami-[a-f0-9]{17}',
            :ConstraintDescription => 'Must be ami-XXXXXXXX (where X is a hexadecimal digit)'

  parameter 'KeyPairName',
            :Description => 'Name of KeyPair to use.',
            :Type => 'String',
            :MinLength => '1',
            :MaxLength => '40',
            :Default => 'kody_pair'

  parameter 'Region',
            :Description => 'Region for deployment',
            :Type => 'String',
            :Default => 'us-east-2',
            :AllowedPattern => '[a-z]{2}-[a-z]{4}-[0-9]',
            :ConstraintDescription => 'Must be valid region id'

  parameter 'Environment',
            :Description => 'sort of environment that have to deploy',
            :Type => 'String',
            :Default => 'qa',
            :AllowedValues => %w(qa prod),
            :ConstraintDescription => 'Must be a listed environment'

  parameter 'VpcId',
            :Description => 'VPC where the environment deploying to',
            :Type => 'String',
            :Default => 'vpc-c81502a0',
            :ConstraintDescription => 'Must be legal VpcId'

  parameter 'Quantity',
            :Description => 'Quantity of availability zones intended for deployment',
            :Type => 'Number',
            :Default => 2,
            :ConstraintDescription => 'Must be equal or less than total number oz zones in a region)'


  vpc = Table.load 'maps/subnets.txt'
#   mapping 'VpcSubnets',
  vpc.get_multihash(:zone, {:visibility => 'ptivate', :region => parameters['Region'], :env => parameters['Environment'], }, :subnet => ['a', 'b', 'c']).each_pair do |key, hashvalue|
    # resource 'Subnet-'+key, :Type => 'AWS::EC2::Subnet', :Properties => {
    #     :VpcId => parameters['VpcId'],
    #     :AvailabilityZone => value[:region]+key,
    #     :CidrBlock => "176.31.48.0/20",
    #     :Tags => [
    #         {:Key => 'AZ',
    #         :Value => value[:mapvalue],
    #         ],
    # }
#   }
  output 'some_keys_and_values1',
        :Value => key,
        :Description => 'Value of "key"'
  output 'some_keys_and_values2',
        :Value => hashvalue[:subnet],
        :Description => 'Value of subnet'

  output 'some_keys_and_values3',
        :Value => key.lenght,
        :Description => 'Value of subnet'

  end
          
  #    get_att(resource, attribute)

  resource 'Subnet1a', :Type => 'AWS::EC2::Subnet', :Properties => {
            :VpcId => parameters['VpcId'],
            :AvailabilityZone => parameters['Region']+'a',
            :CidrBlock => "172.31.48.0/20",
            :Tags => [
                {:Key => 'AZ',
                #  :Value => value[:mapvalue]
                :Value => 'a'
                }]
            }

  resource 'Subnet1b', :Type => 'AWS::EC2::Subnet', :Properties => {
            :VpcId => parameters['VpcId'],
            :AvailabilityZone => parameters['Region']+'b',
            :CidrBlock => "172.31.64.0/20",
            :Tags => [
                {:Key => 'AZ',
                #  :Value => value[:mapvalue]
                :Value => 'b'
                }]
            }

  resource 'Subnet1c', :Type => 'AWS::EC2::Subnet', :Properties => {
            :VpcId => parameters['VpcId'],
            :AvailabilityZone => parameters['Region']+'c',
            :CidrBlock => "172.31.80.0/20",
            :Tags => [
                {:Key => 'AZ',
                #  :Value => value[:mapvalue]
                :Value => 'c'
                }]
            }

  resource 'RouteTableInternal', :Type => 'AWS::EC2::RouteTable', :Properties => {
            :VpcId => parameters['VpcId'],
            :Tags => [{:Key => 'Name', :Value => 'Internal-RT'}]
            }

  resource 'SubnetRtAssociationA', :Type => 'AWS::EC2::SubnetRouteTableAssociation',
            :Properties => {
                :RouteTableId => ref('RouteTableInternal'),
                :SubnetId => ref('Subnet1a')
            }
  
  resource 'SubnetRtAssociationB', :Type => 'AWS::EC2::SubnetRouteTableAssociation',
            :Properties => {
                :RouteTableId => ref('RouteTableInternal'),
                :SubnetId => ref('Subnet1b')
            }

  resource 'SubnetRtAssociationC', :Type => 'AWS::EC2::SubnetRouteTableAssociation',
            :Properties => {
                :RouteTableId => ref('RouteTableInternal'),
                :SubnetId => ref('Subnet1c')
            }


  resource 'Route', :Type => '', :Properties => {
    :DestinationCidrBlock => "0.0.0.0/0",
    :RouteTableId => ref('RouteTableInternal'),
    # :NatGatewayId     # HAVE TO BE but costs MONEY
    # :DestinationIpv6CidrBlock
    # :EgressOnlyInternetGatewayId
    :GatewayId => ref()
    # :InstanceId
    # :NetworkInterfaceId
    # :VpcPeeringConnectionId      
  }


  resource 'SecurityGroup', 
            :Type => 'AWS::EC2::SecurityGroup', 
            :Properties => {
                :VpcId => parameters['VpcId'],
                :GroupDescription => 'route http traffic to load balancer',
                :SecurityGroupIngress => {
                    :IpProtocol => 'TCP', 
                    :FromPort => 80, 
                    :ToPort => 80, 
                    :CidrIp => "0.0.0.0/0"},
                :SecurityGroupEgress => {
                    :IpProtocol => '-1', 
                    :FromPort => 0, 
                    :ToPort => 0, 
                    :CidrIp => "0.0.0.0/0"}
            }

  resource 'LaunchConfig', 
            :Type => 'AWS::AutoScaling::LaunchConfiguration', 
            :Properties => {
                :ImageId => parameters['ImageId'],
                :KeyName => ref('KeyPairName'),
                :InstanceType => ref('InstanceType'),
                :SecurityGroups => [ref('SecurityGroup')],
                # :UserData => base64(interpolate(file('userdata.sh'), time: Time.now)),
            }

  resource "ASG", 
            :Type => 'AWS::AutoScaling::AutoScalingGroup', 
            :Properties => {
                :AvailabilityZones => ['us-east-2a', 'us-east-2b', 'us-east-2c'],
                # :AvailabilityZones => [get_azs(parameters['Region'])],  # doesn't work
                :LaunchConfigurationName => ref('LaunchConfig'),
                :TargetGroupARNs => [ref('AlbTargetGroup')],
                :VPCZoneIdentifier => [ref('Subnet1a', 'Subnet1b', 'Subnet1c')],
                :HealthCheckType => 'EC2',
                :MinSize => 1,
                :MaxSize => 5,
                :DesiredCapacity => 2,
                # :NotificationConfiguration => {
                #     :TopicARN => ref('EmailSNSTopic'),
                #     :NotificationTypes => %w(autoscaling:EC2_INSTANCE_LAUNCH autoscaling:EC2_INSTANCE_LAUNCH_ERROR autoscaling:EC2_INSTANCE_TERMINATE autoscaling:EC2_INSTANCE_TERMINATE_ERROR),
                # },
                :Tags => [
                    {
                    :Key => 'Name',
                    :Value => parameters['Label'],
                    :PropagateAtLaunch => 'true',
                    }
                ],
            }
    
  resource "ALB",
            :Type => 'AWS::ElasticLoadBalancingV2::LoadBalancer',
            :Properties => {
                # :IpAddressType: 'String',
                :Name => ref('Label'),
                :Type => 'application',
                # :Scheme => 'internet-facing',
                :SecurityGroups => [ref('SecurityGroup')],
                # :SubnetMappings => [
                #   SubnetMapping property types; at least 2; no more than 1 per AZ
                # ],
                :Subnets => [
                    'subnet-661f200e', 
                    'subnet-46afda3c',
                    'subnet-cc924e80'
                  # subnet IDs list; at least 2; no more than 1 per AZ
                ],
                :Tags => [
                    {:Key =>'Name', :Value => 'App-Load-Balancer'}
                ]
            }

  resource "AlbTargetGroup",
            :Type => 'AWS::ElasticLoadBalancingV2::TargetGroup',
            :Properties => {
                :HealthCheckIntervalSeconds  => 30,
                # :HealthCheckPath => String,   # default is '/'
                # :HealthCheckPort => '80', # default is traffic port
                # :HealthCheckProtocol => 'HTTP', # defaults are 'HTTP'/'TCP'
                # :Matcher => "200-299",     # default is "200", doasn't work here
                :HealthCheckTimeoutSeconds => 3,
                :HealthyThresholdCount => 2,
                :UnhealthyThresholdCount => 2,
                :Name => ref('Label'),
                :Port => 80,
                :Protocol => 'HTTP',
                :Tags => [
                    {:Key =>'Name', :Value => 'ALB-target-group',}
                ],
                # :TargetType => 'instance', # defalt is 'instance' Valid Values: instance | ip | lambda
                :VpcId => parameters['VpcId']
            }

  resource "AlbListener",
            :Type => 'AWS::ElasticLoadBalancingV2::Listener',
            :Properties => {
                :DefaultActions => [{
                    :Type => 'forward',
                    :TargetGroupArn => ref('AlbTargetGroup')
                }],
                :LoadBalancerArn => ref('ALB'),
                :Port => 80,
                :Protocol => 'HTTP',    # supported values are 'HTTP' and 'HTTPS'
                # :SslPolicy: String
                # :Certificates => Certificate
            }


end

tmpl.exec!