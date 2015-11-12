module Views
	module ActionView
		# ::ActionView::Template is one class in Rails
		module Template
			include Views::ActionView::ViewPaths

			def self.extended(mod)
				::ActionView::Template.send(:include, self)
			end

			def self.included(mod)
				mod.remove_existing_instance_methods(self)
			end

	    # Render a template. If the template was not compiled yet, it is done
	    # exactly before rendering.
	    #
	    # This method is instrumented as "!render_template.action_view". Notice that
	    # we use a bang in this instrumentation because you don't want to
	    # consume this in production. This is only slow if it's being listened to.
	    def render(view, locals, buffer=nil, &block)
	      instrument("!render_template") do
	        compile!(view)
	        view.send(method_name, locals, buffer, &block)
	      end
	    rescue => e
	      handle_render_error(view, e)
	    end
		end
	end
end