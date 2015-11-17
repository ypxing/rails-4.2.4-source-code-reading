module ModuleSwitch
  def enable(target_mod = target_const)
    target_mod.send(:prepend, shim_const)
    shim_const.copy_existing_instance_methods(self)
  end

  def disable
    target_const.remove_instance_methods_from_ancestors("#{name}::SHIM")
  end

  def shim_const
    @shim ||= const_defined?('SHIM') ? const_get('SHIM') :
      const_set('SHIM', Module.new{ def self.prepended(mod); mod.remove_instance_methods_from_ancestors(name); super; end })
  end

  def target_const
    @target ||= const_get(name.gsub(/\AViews/, ''))
  end
end