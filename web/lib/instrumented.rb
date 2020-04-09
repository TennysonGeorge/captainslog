module Instrumented
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    # Wraps a method and traces its call. The span's operation name will be
    # <class name>.<method name>.
    #
    # @param [Array<Symbol>] method_name
    def traced(*method_names)
      proxy = Module.new

      method_names.each do |method_name|
        operation_name = "#{name}.#{method_name}"
        proxy.define_method(method_name) do |*args, &block|
          OpenTracing.start_active_span(operation_name) do
            super(*args, &block)
          end
        end
      end

      prepend proxy
    end
  end

  # @param [OpenTracing::Span, nil] span
  def with_active_span(span)
    OpenTracing.global_tracer.scope_manager.activate(span, :finish_on_close => false) if span
    yield
  end
end
