# lib/action_view/view_paths.rb
module Views
	module ActionView
		module ViewPaths
			include Views::ActionView::Layouts

			# irb(main):027:0> controller._prefixes
			# => ["users", "application"]
			# irb(main):028:0> controller.details_for_lookup
			# => {}
			def lookup_context
	      @_lookup_context ||=
	        ::ActionView::LookupContext.new(controller.class._view_paths, controller.details_for_lookup, controller._prefixes)
			end
		end
	end
end