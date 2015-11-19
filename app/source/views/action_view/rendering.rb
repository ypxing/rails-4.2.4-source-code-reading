# lib/action_view/rendering.rb
module Views
	module ActionView
		module Rendering
			extend ModuleSwitch

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

      # Assign the rendered format to lookup context.
      def _process_format(format, options = {}) #:nodoc:
        super

        # before the assignment, lookup_context.formats is
        # [:html, :text, :js, :css, :ics, :csv, :vcf, :png, :jpeg, :gif, :bmp, :tiff, :mpeg, :xml, :rss, :atom, :yaml, :multipart_form, :url_encoded_form, :json, :pdf, :zip]
        # after the assignment, it is [:html]
        lookup_context.formats = [format.to_sym]
        lookup_context.rendered_format = lookup_context.formats.first
      end

      # Normalize args by converting render "foo" to render :action => "foo" and
      # render "foo/bar" to render :template => "foo/bar".
      # :api: private
      def _normalize_args(action=nil, options={})
        options = super(action, options)
        case action
        when NilClass
        when Hash
          options = action
        when String, Symbol
          action = action.to_s
          key = action.include?(?/) ? :template : :action
          options[key] = action
        else
          options[:partial] = action
        end

        options
      end

      # Normalize options.
      # :api: private
      def _normalize_options(options)
        options = super
        if options[:partial] == true
          options[:partial] = action_name
        end

        if (options.keys & [:partial, :file, :template]).empty?
          options[:prefixes] ||= _prefixes
        end

        options[:template] ||= (options[:action] || action_name).to_s
        options
      end
		end
	end
end