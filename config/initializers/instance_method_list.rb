class Module
  def instance_method_list(instance_method, location = true)
    ancestors.find_all do |ancestor|
      (ancestor.instance_methods(false) + ancestor.private_instance_methods(false)).include?(instance_method)
    end
	.map { |x| x.instance_method(instance_method) }
	.map { |m| location ? m.source_location : m }
  end

  def supermodule
  	ancestors[ancestors.index(self) + 1]
  end

  def remove_existing_instance_methods(mod)
    methods = Module === mod ?
      (mod.instance_methods(false) + mod.private_instance_methods(false)) : Array(mod)

    methods.each do |m|
      remove_method(m) rescue nil
    end
  end
end
