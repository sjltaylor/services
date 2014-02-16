class Services
  class Container
    def self.modules
      search_path = './app/services/'
      Dir["#{search_path}**/*_services.rb"].reduce([]) do |memo, path|
        require path
        name_with_namespace = path[search_path.length..-(1 + File.extname(path).length)]
        constant = name_with_namespace.camelize.constantize
        memo.push(constant) if constant.instance_of?(Module)
        memo
      end
    end

    modules.each {|m| include m }
  end
end