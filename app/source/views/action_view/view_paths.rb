# lib/action_view/view_paths.rb
module Views
	module ActionView
		module ViewPaths
			SHIM = self.dup


			def self.prepended(mod)
				binding.pry
			end

			def self.enable
				::ActionView::ViewPaths.send(:prepend, SHIM)
			end

			def self.disable
				::ActionView::ViewPaths.send(:prepend, SHIM)
			end

			# irb(main):027:0> controller._prefixes
			# => ["users", "application"]
			# irb(main):028:0> controller.details_for_lookup
			# => {}
			def lookup_context
	      @_lookup_context ||=
	        ::ActionView::LookupContext.new(self.class._view_paths, details_for_lookup, _prefixes)
			end
		end
	end
end

# ActionView::ViewPaths.send(:prepend, Views::ActionView::ViewPaths)