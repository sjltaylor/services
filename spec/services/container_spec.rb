require 'spec_helper'

describe Services::Container do
  let(:container) { described_class.new }

  describe '#protect' do
    it 'returns a Services::Sentry' do
      container.protect.should be_instance_of Services::Sentry
    end
    describe 'the returned Service::Sentry' do
      let(:sentry) { container.protect }
      it 'has the Services::Container instance as it container' do
        sentry.protected_object.should be container
      end
    end
    describe '.allow(service_name)' do
      let(:klass) { Class.new(described_class) }
      it 'defines a permissions predicate which takes any arguments and returns true' do
        klass.allow(:service)
        instance = klass.new
        instance.methods.should include :allow_service?
        method = instance.method(:allow_service?)
        method.parameters[0][0].should == :rest
      end
    end
  end
end