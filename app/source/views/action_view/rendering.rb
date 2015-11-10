# lib/action_view/rendering.rb
module Views
	module ActionView
		module Rendering
			include Views::ActionView::Layouts

	    def render_to_body(options = {})
	      _process_options(options)
	      controller.send(:_render_template, options)
	    end
		end
	end
end