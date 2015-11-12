# action_view/renderer/renderer.rb
module Views
	module ActionView
		module Renderer
			module Renderer
				include Views::ActionView::ViewPaths

				def view_renderer
					@_view_renderer ||= Views::ActionView::Renderer::Renderer::Renderer.new(lookup_context)
				end

				class Renderer

			    attr_accessor :lookup_context

			    def initialize(lookup_context)
			      @lookup_context = lookup_context
			    end

					# ActionView::Render's instance method render
			    def render(context, options)
			      if options.key?(:partial)
			        render_partial(context, options)
			      else
			        render_template(context, options)
			      end
			    end

			    # # Render but returns a valid Rack body. If fibers are defined, we return
			    # # a streaming body that renders the template piece by piece.
			    # #
			    # # Note that partials are not supported to be rendered with streaming,
			    # # so in such cases, we just wrap them in an array.
			    # def render_body(context, options)
			    #   if options.key?(:partial)
			    #     [render_partial(context, options)]
			    #   else
			    #     StreamingTemplateRenderer.new(@lookup_context).render(context, options)
			    #   end
			    # end

			    # ActionView::Render's instance method
			    # Direct accessor to template rendering.
			    def render_template(context, options) #:nodoc:
			      ::ActionView::TemplateRenderer.new(lookup_context).render(context, options)
			    end

			    # ActionView::Render's instance method
			    # Direct access to partial rendering.
			    def render_partial(context, options, &block) #:nodoc:
			      ::ActionView::PartialRenderer.new(lookup_context).render(context, options, block)
			    end
				end
			end
		end
	end
end