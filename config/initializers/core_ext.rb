class Module
  def instance_method_inheritance_list(instance_method, location = true)
    ancestors.find_all do |ancestor|
      (ancestor.public_instance_methods(false) +
        ancestor.protected_instance_methods(false) +
        ancestor.private_instance_methods(false)).include?(instance_method)
    end
    .map do |x|
      m = x.instance_method(instance_method)
      m.respond_to?(:super_method) && m.super_method ? m.super_method : m
    end
  	.map { |m| location ? m.source_location : m }.uniq
  end

  # def supermodule(target = self)
  # 	ancestors[ancestors.index(target) + 1]
  # end

  def remove_existing_instance_methods(mod)
    methods = Module === mod ?
      (mod.public_instance_methods(false) + mod.private_instance_methods(false) + mod.protected_instance_methods(false)) : Array(mod)

    methods.each do |m|
      remove_method(m) rescue nil
    end
  end

  def copy_existing_instance_methods(mod, template = mod)
    ['public', 'private', 'protected'].each do |perm|
      perm_s = "#{perm}_"
      template.send("#{perm_s}instance_methods", false).each do |m|
        define_method(m, mod.instance_method(m))
        send("#{perm}", m)
      end
    end
  end

  def prefix_existing_instance_methods(prefix, template = self, remove_prefix = false)
    ['public', 'private', 'protected'].each do |perm|
      perm_s = "#{perm}_"

      template.send("#{perm_s}instance_methods", false).each do |m|
        new_name, old_name =
          if remove_prefix
            template == self ? [m[prefix.size..-1], m] : [m, "#{prefix}#{m}"]
          else
            ["#{prefix}#{m}", m]
          end

        next unless send("#{perm_s}instance_methods", false).include?(old_name.to_sym)

        define_method(new_name, instance_method(old_name))
        send("#{perm}", new_name)
        remove_method(old_name)
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