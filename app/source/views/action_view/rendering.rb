# lib/action_view/rendering.rb
module Views
	module ActionView
		module Rendering
			include Views::ActionView::Layouts

			def lookup_context
				controller.lookup_context
			end
		end
	end
end