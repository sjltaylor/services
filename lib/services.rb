require 'active_support/inflector'
require 'resolve'
require 'services/version'
require 'services/container'

class Services
  class NotAllowed < StandardError; end

  def initialize(opts={})
    @container = Container.resolve(opts)
  end

  def respond_to?(method_name)
    super || @container.respond_to?(method_name)
  end

  def method_missing(method_name, *args, &block)
    container = @container

    super unless container.respond_to?(method_name)
    (class << self; self; end).send(:define_method, method_name) do |*m_args|
      raise_unless_allowed(method_name, *m_args)
      return container.send(method_name, *m_args, &block)
    end
    send(method_name, *args, &block)
  end

  def raise_unless_allowed(operation, context)
    predicate_name = "#{operation}?"
    raise NotAllowed unless @container.respond_to?(predicate_name) && @container.send(predicate_name, context)
    return nil
  end
end
