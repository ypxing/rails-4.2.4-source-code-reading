# action_view/renderer/renderer.rb
module Views
	module ActionView
		module Renderer
			module Renderer

				include Rendering

				def _render
					puts "+++lib/action_view/renderer/renderer.rb+++"
					view_renderer.render(view_context, options)
					# just calls view_renderer.render_template(view_context, options)
				end
			end
		end
	end
end