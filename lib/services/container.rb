module Services
  class Container
    def protect
      Sentry.new(self)
    end
    def self.allow(service)
      send(:define_method, "allow_#{service}?"){|*args| true}
    end
  end
end