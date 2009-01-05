class ActiveSupport::Callbacks::Callback
  def should_run_callback?(*args)
    [options[:if]].flatten.compact.all? { |a| evaluate_method(a, *args) } &&
      ![options[:unless]].flatten.compact.any? { |a| evaluate_method(a, *args) }
  end
end
