require 'pathname'
require 'active_support/inflector'
require 'services/version'
require 'services/container'
require 'services/sentry'

module Services
  module_function

  def modules_in(search_path)
    search_path = Pathname.new(search_path).expand_path.to_s

    Dir["#{search_path}/**/*_services.rb"].reduce([]) do |memo, path|
      require path
      name_with_namespace = path[search_path.length..-(1 + File.extname(path).length)]
      constant = name_with_namespace.camelize.constantize
      memo.push(constant) if constant.instance_of?(Module)
      memo
    end
  end

  def from(path)
    Class.new(Container).tap do |klass|
      klass.include(*modules_in(path))
      klass.instance_variable_set(:@services_path, path)
    end
  end
end
