require 'spec_helper'

describe Services::Container do
  it 'includes all services modules from app/services' do
    described_class.included_modules.should include(Api::ApiServices, EmailServices, PhotoServices)
  end

  describe '.modules' do
    let(:modules) { described_class.modules }
    it 'is an array' do
      modules.should be_instance_of Array
    end
    it 'includes service modules' do
      modules.should include(PhotoServices, EmailServices)
    end
    it 'does not include modules in files with names not ending in "_services.rb"' do
      modules.should_not include(ModuleFile)
    end
    it 'does not include classes' do
      modules.should_not include(ClassFile)
      modules.should_not include(Api::ApiConnector)
    end
    it 'does not include classes with file names ending in _services.rb' do
      modules.should_not include(ClassServices)
    end
    it 'includes modules within subdirectories' do
      modules.should include(Api::ApiServices)
    end
  end
end