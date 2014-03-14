require 'pathname'
require 'active_support/inflector'
require 'services/version'
require 'services/container'

module Services
  module_function

  def modules_in(search_path)
    search_path = Pathname.new(search_path).expand_path.to_s

    Dir["#{search_path}/**/*.rb"].reduce([]) do |memo, path|
      # if rails is defined rely on the autoloader to that changes
      # are picked up by the Rails auto reload system
      require path unless defined? Rails
      # the full path of the file excluding its extension and the search_path prefix
      name_with_namespace = path[search_path.length..-(1 + File.extname(path).length)]
      # assume the namespace and name correspond to the file path relative to the search path
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
