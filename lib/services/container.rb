module Services
  class Container
    def protect
      Sentry.new(self)
    end
  end
end