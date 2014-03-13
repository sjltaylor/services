module Services
  module PermissionsDsl
    def allow(service)
      send(:define_method, "allow_#{service}?"){|*args| true}
    end
  end
end
