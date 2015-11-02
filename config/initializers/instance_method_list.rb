class Module
  def instance_method_list(instance_method, location = true)
    ancestors.find_all do |ancestor|
      (ancestor.instance_methods(false) + ancestor.private_instance_methods(false)).include?(instance_method)
    end
	.map { |x| x.instance_method(instance_method) }
	.map { |m| location ? m.source_location : m }
  end
end