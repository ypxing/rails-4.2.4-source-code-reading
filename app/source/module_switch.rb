module ModuleSwitch
  def enable(shadow_target = true)
    insert unless @inserted
    target_const.prefix_existing_instance_methods('__module_switch', self) if shadow_target
    shim_const.copy_existing_instance_methods(self)
  end

  def disable
    target_const.prefix_existing_instance_methods('__module_switch', self, true)
    target_const.remove_instance_methods_from_ancestors("#{name}::SHIM")
  end

  def insert
    @inserted ||=
      begin
        target_const.send(:prepend, shim_const)
        true
      end
  end

  def shim_const
    @shim ||= const_defined?('SHIM') ? const_get('SHIM') :
      const_set('SHIM', Module.new{ def self.prepended(mod); mod.remove_instance_methods_from_ancestors(name); super; end })
  end

  def target_const
    @target ||= default_target
  end

  def target_const=(target = default_target)
    @target = target
  end

  def default_target
    const_get(name.gsub(/\A[^:]*/, ''))
  end
end