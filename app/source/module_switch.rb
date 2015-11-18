module ModuleSwitch
  def enable(target_mod = target_const)
    insert unless @inserted
    shim_const.copy_existing_instance_methods(self)
  end

  def disable
    target_const.remove_instance_methods_from_ancestors("#{name}::SHIM")
  end

  def insert(target_mod = target_const)
    unless @inserted
      @inserted = true

      target_mod.send(:prepend, shim_const)
      target_mod.module_eval do
        define_method :super_method do |method_name, *args|
          self.class.supermodule(target_mod).instance_method(method_name).bind(self).call(*args)
        end
      end
    end
  end

  def shim_const
    @shim ||= const_defined?('SHIM') ? const_get('SHIM') :
      const_set('SHIM', Module.new{ def self.prepended(mod); mod.remove_instance_methods_from_ancestors(name); super; end })
  end

  def target_const
    @target ||= const_get(name.gsub(/\A[^:]*/, ''))
  end
end