module ModuleSwitch
  def enable(target_mod = target_const)
    insert unless @inserted
    remove_methods_from_target
    shim_const.copy_existing_instance_methods(self)
  end

  def disable
    insert_methods_back_to_target
    target_const.remove_instance_methods_from_ancestors("#{name}::SHIM")
  end

  def insert(target_mod = target_const)
    @inserted ||=
      begin
        target_mod.send(:prepend, shim_const)
        true
      end
  end

  def shim_const
    @shim ||= const_defined?('SHIM') ? const_get('SHIM') :
      const_set('SHIM', Module.new{ def self.prepended(mod); mod.remove_instance_methods_from_ancestors(name); super; end })
  end

  def method_bank
    @m_bank ||= const_defined?('BANK') ? const_get('BANK') : const_set('BANK', target_const.instance_of?(Class) ? Class.new(target_const) : Module.new)
  end

  def remove_methods_from_target
    insert_methods_back_to_target
    method_bank.copy_existing_instance_methods(target_const, self)
    target_const.remove_existing_instance_methods(self)
  end

  def insert_methods_back_to_target
    target_const.copy_existing_instance_methods(method_bank)
    method_bank.remove_existing_instance_methods(method_bank)
  end

  def target_const
    @target ||= const_get(name.gsub(/\A[^:]*/, ''))
  end
end