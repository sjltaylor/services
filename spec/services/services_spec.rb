require 'spec_helper'

describe Services do
  # see app/services skeleton rails app excerpt for expected file layout
  let(:opts) { { my_service: :my_service } }
  let(:services) { Services.resolve(opts) }

  describe 'services container' do
    let(:container) { services.instance_variable_get(:@container) }

    it 'is created with all service dependencies satisfied (using Resolve)' do
      container.my_service.should eq :my_service
      container.class_file.should be_instance_of ClassFile
      container.api_connector.should be_instance_of Api::ApiConnector
    end
    it 'is an instance of Services::Container' do
      container.should be_instance_of Services::Container
    end
  end

  describe 'service function proxying' do
    let(:container) { double(:container) }
    let(:context) { double(:context) }

    before(:each) { services.instance_variable_set(:@container, container) }

    describe 'checking for permission' do
      before(:each) { container.stub(:my_service_function) }
      before(:each) { services.stub(:raise_unless_allowed) }

      it 'calls raise_unless_allowed before the service function' do
        container.stub(:service_function)
        services.stub(:raise_unless_allowed).with(:service_function, context) do
          container.should_not have_received(:service_function)
        end
        services.service_function(context)
        services.should have_received(:raise_unless_allowed).with(:service_function, context)
      end
    end
    it 'returns the value from the service function' do
      container.stub(:service_function?).and_return(true)
      container.stub(:service_function).and_return('results of service function call')
      services.service_function(context).should == 'results of service function call'
    end
    it 'passes the context to the service function' do
      container.stub(:service_function?).and_return(true)
      container.stub(:service_function)
      services.service_function(context)
      container.should have_received(:service_function).with(context)
    end

    describe '#respond_to?' do
      it 'returns true if the instance responds to a method' do
        services.should respond_to :to_s
      end
      it 'returns true if the services modules responds to a method' do
        def container.send_email(opts={})
        end
        services.should respond_to :send_email
      end
      it 'returns false if neither the instance or any of the service modules define a method' do
        services.should_not respond_to :howl_like_a_wolf
      end
    end
  end

  describe '#raise_unless_allowed' do
    let(:container) { double(:container) }
    let(:context) { double(:context) }
    let(:operation_name) { :restricted_operation }
    let(:predicate_name) { "#{operation_name}?".to_sym }
    let(:allowed) { true }

    before(:each) { container.stub(predicate_name).and_return(allowed) }
    before(:each) { services.instance_variable_set(:@container, container) }

    def raise_unless_allowed
      services.raise_unless_allowed(operation_name, context)
    end

    describe 'parameter passing' do
      before(:each) { raise_unless_allowed }

      it 'passes the context to the predicate' do
        container.should have_received(predicate_name).with(context)
      end
    end

    context 'when the operation is allowed' do

      # it returns parametes so that any resources which had to be
      # retrived, such as database records, can be reused by the
      # calling function
      it 'returns nil' do
        raise_unless_allowed.should be_nil
      end
    end

    context 'when the operation is prohibited' do
      let(:allowed) { false }

      it 'raises a Services::NotAllowed' do
        expect{raise_unless_allowed}.to raise_error(Services::NotAllowed)
      end
    end

    context 'when a permissions predicate is not defined' do
      let(:container) { Object.new }
      let(:predicate_name) { :none_existant_predicate? }
      it 'raises a Services::NotAllowed' do
        expect{raise_unless_allowed}.to raise_error(Services::NotAllowed)
      end
    end
  end
end
