module Services
  class Sentry
    class NotAllowed < StandardError; end

    attr_reader :protected_object

    def initialize(protected_object)
      @protected_object = protected_object
    end

    def respond_to?(method_name)
      super || @protected_object.respond_to?(method_name)
    end

    def method_missing(method_name, *args, &block)
      protected_object = @protected_object

      super unless protected_object.respond_to?(method_name)

      if method_name =~ /\Aallow_\w+\?\Z/
        (class << self; self; end).send(:define_method, method_name) do |*m_args|
          return protected_object.send(method_name, *m_args, &block)
        end
      else
        (class << self; self; end).send(:define_method, method_name) do |*m_args|
          raise_unless_allowed(method_name, *m_args)
          return protected_object.send(method_name, *m_args, &block)
        end
      end

      send(method_name, *args, &block)
    end

    def raise_unless_allowed(operation, context)
      predicate_name = :"allow_#{operation}?"
      raise NotAllowed unless @protected_object.respond_to?(predicate_name) && @protected_object.send(predicate_name, context)
      return nil
    end
  end
end