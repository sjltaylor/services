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
  end
end