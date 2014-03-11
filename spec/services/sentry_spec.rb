require 'spec_helper'

describe Services::Sentry do
  let(:protected_object) { double(:protected_object) }
  let(:sentry) { described_class.new(protected_object) }

  describe 'service function proxying' do
    let(:context) { double(:context) }

    describe 'checking for permission' do
      before(:each) { protected_object.stub(:my_service_function) }
      before(:each) { sentry.stub(:raise_unless_allowed) }

      it 'calls raise_unless_allowed before the service function' do
        protected_object.stub(:service_function)
        sentry.stub(:raise_unless_allowed).with(:service_function, context) do
          protected_object.should_not have_received(:service_function)
        end
        sentry.service_function(context)
        sentry.should have_received(:raise_unless_allowed).with(:service_function, context)
      end
    end
    it 'returns the value from the service function' do
      protected_object.stub(:allow_service_function?).and_return(true)
      protected_object.stub(:service_function).and_return('results of service function call')
      sentry.service_function(context).should == 'results of service function call'
    end
    it 'passes the context to the service function' do
      protected_object.stub(:allow_service_function?).and_return(true)
      protected_object.stub(:service_function)
      sentry.service_function(context)
      protected_object.should have_received(:service_function).with(context)
    end

    describe 'calling a permissions predicate' do
      before(:each) do
        protected_object.stub(:allow_permissions_check?).with(context).and_return(:return_value)
      end

      it 'calls the methods without checking for permission' do
        sentry.allow_permissions_check?(context).should be :return_value
      end
    end

    describe '#respond_to?' do
      it 'returns true if the instance responds to a method' do
        sentry.should respond_to :to_s
      end
      it 'returns true if the protected_object responds to a method' do
        def protected_object.send_email(opts={})
        end
        sentry.should respond_to :send_email
      end
      it 'returns false if neither the instance or any of the service modules define a method' do
        sentry.should_not respond_to :howl_like_a_wolf
      end
    end
  end

  describe '#raise_unless_allowed' do
    let(:context) { double(:context) }
    let(:operation_name) { :restricted_operation }
    let(:predicate_name) { "allow_#{operation_name}?".to_sym }
    let(:allowed) { true }

    before(:each) { protected_object.stub(predicate_name).and_return(allowed) }
    before(:each) { sentry.instance_variable_set(:@protected_object, protected_object) }

    def raise_unless_allowed
      sentry.raise_unless_allowed(operation_name, context)
    end

    describe 'parameter passing' do
      let(:predicate_arity) { -1 }
      let(:predicate_method) { double(:predicate_method, arity: predicate_arity) }
      before(:each) { raise_unless_allowed }
      before(:each) do
        protected_object.stub(:method).with(predicate_name).and_return(predicate_method)
      end

      describe 'when the predicate has a non-zero arity' do
        it 'passes the context to the predicate' do
          protected_object.should have_received(predicate_name).with(context)
        end
      end

      describe 'when the predicate has a zero arity' do
        def raise_unless_allowed
          sentry.raise_unless_allowed(operation_name)
        end
        it 'passes nothing to the predicate' do
          protected_object.should have_received(predicate_name).with(no_args)
        end
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
        expect{raise_unless_allowed}.to raise_error(Services::Sentry::NotAllowed)
      end
    end

    context 'when a permissions predicate is not defined' do
      let(:protected_object) { Object.new }
      let(:predicate_name) { :allow_none_existant_predicate? }
      it 'raises a Services::NotAllowed' do
        expect{raise_unless_allowed}.to raise_error(Services::Sentry::NotAllowed)
      end
    end
  end
end
