require 'spec_helper'

describe Services do
  # see app/services skeleton rails app excerpt for expected file layout
  let(:path) { 'app/services' }

  describe '.from(path)' do
    let(:services_klass) { described_class.from(path) }
    let(:modules) { [ Api::ApiServices, EmailServices, PhotoServices ] }

    before(:each) { Services.stub(:modules_in).with(path).and_return(modules) }

    it 'is an instance of Services::Container' do
      services_klass.should be < Services::Container
    end

    describe '@services_path' do
      it 'is set to that from which the services were loaded' do
        services_klass.instance_variable_get(:@services_path).should == path
      end
    end

    it 'includes all services modules from the specified path' do
      services_klass.included_modules.should include(*modules)
    end
  end

  describe '.modules_in(path)' do
    let(:modules) { described_class.modules_in(path) }

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
