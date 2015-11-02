module Views
	module ActionView
		module Renderer
			module TemplateRenderer
				include Renderer::Renderer

				attr_accessor :template_renderer, :template

				def prepare
					super

					@template_renderer = ::ActionView::TemplateRenderer.new(lookup_context)
					@template_renderer.instance_variable_set(:@view, view_context)
					details_in_template_renderer = template_renderer.send :extract_details, options
					keys_in_template_renderer = options.has_key?(:locals) ? options[:locals].keys : []

					@template = template_renderer.find_template(options[:template],
																										  options[:prefixes],
																										  false, # partial or not
																										  keys_in_template_renderer,
																										  details_in_template_renderer)
				end

				def _render
					
				end
			end
		end
	end
end