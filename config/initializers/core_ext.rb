class Module
  def instance_method_list(instance_method, location = true)
    ancestors.find_all do |ancestor|
      (ancestor.instance_methods(false) +
        ancestor.protected_instance_methods(false) +
        ancestor.private_instance_methods(false)).include?(instance_method)
    end
  	.map { |x| x.instance_method(instance_method) }
  	.map { |m| location ? m.source_location : m }.uniq
  end

  def supermodule(target = self)
  	ancestors[ancestors.index(target) + 1]
  end

  def remove_existing_instance_methods(mod)
    methods = Module === mod ?
      (mod.instance_methods(false) + mod.private_instance_methods(false) + mod.protected_instance_methods(false)) : Array(mod)

    methods.each do |m|
      remove_method(m) rescue nil
    end
  end

  def copy_existing_instance_methods(mod)
    [nil, 'private', 'protected'].each do |perm|
      perm_s = "#{perm ? perm + '_' : ''}"
      mod.send("#{perm_s}instance_methods", false).each do |m|
        define_method(m, mod.instance_method(m))
        send("#{perm}", m) if perm
      end
    end
  end

  def remove_instance_methods_from_ancestors(anc_name)
    ancestors.each do |anc|
      # just reset all SHIM module
      anc.remove_existing_instance_methods(anc) if anc.name == anc_name
    end
  end
end