module ModuleSwitch
  def enable(target_mod = target_const)
    target_mod.send(:prepend, shim_const)
    shim_const.copy_existing_instance_methods(self)
  end

  def disable
    shim_const.remove_existing_instance_methods(shim_const)
  end

  def shim_const
    @shim ||= const_defined?('SHIM') ? const_get('SHIM') :
      const_set('SHIM', Module.new do
        def self.prepended(mod)
          mod.ancestors.each do |anc|
            # just reset all SHIM module
            anc.remove_existing_instance_methods(anc) if anc.name == name
          end
        end
      end)
  end

  def target_const
    @target ||= const_get(name.gsub(/\AViews/, ''))
  end
end