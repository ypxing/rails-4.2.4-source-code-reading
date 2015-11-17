# lib/action_view/rendering.rb
module Views
	module ActionView
		module Rendering
			include Views::AbstractController::Rendering

	    def render_to_body(options = {})
	    	# in Views::AbstractController::Rendering
	      _process_options(options)

	      _render_template(options)
	    end

	    def view_renderer
	    	@_view_renderer ||= ::ActionView::Renderer.new(lookup_context)
	    end

	    def view_context
	    	# view_assigns is defined in abstract controller
	    	# view_context_class.new(view_renderer, view_assigns, self)
        # each pair (key/value) in view_assigns will become one instance variable
        # and its value in instance of view_context_class.
	    	view_context_class.new(view_renderer, view_assigns, controller)
	    end

	    # it's one class method in Rails source code
      def view_context_class
        @view_context_class ||= begin
        	# supports_path?: only action controller supports path
        	# email only supports full url
          supports_path = controller.class.supports_path?
          routes  = controller.class.respond_to?(:_routes)  && controller.class._routes
          helpers = controller.class.respond_to?(:_helpers) && controller.class._helpers

          Class.new(::ActionView::Base) do
            if routes
              include routes.url_helpers(supports_path)
              include routes.mounted_helpers
            end

            if helpers
              include helpers
            end
          end
        end
      end

    private

      # Find and render a template based on the options given.
      # :api: private
      def _render_template(options) #:nodoc:

        if options.delete(:stream)
          Rack::Chunked::Body.new view_renderer.render_body(view_context, options)
        else
          # super
	        variant = options[:variant]

	        lookup_context.rendered_format = nil if options[:formats]
	        lookup_context.variants = variant if variant

	        view_renderer.render(view_context, options)
        end

      end
		end
	end
end