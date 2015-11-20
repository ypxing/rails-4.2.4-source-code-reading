# lib/action_view/rendering.rb
module Views
  module ActionView
    module Rendering
      extend ModuleShims::Switch

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
        # each pair (key/value) in view_assigns will become one instance variable
        # and its value in instance of view_context_class.
        view_context_class.new(view_renderer, view_assigns, self)
      end

      # it's one class method in Rails source code
      def view_context_class
        @view_context_class ||= begin
          # supports_path?: only action controller supports path
          # email only supports full url
          supports_path = self.class.supports_path?
          routes  = self.class.respond_to?(:_routes)  && self.class._routes
          helpers = self.class.respond_to?(:_helpers) && self.class._helpers

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
        variant = options[:variant]

        lookup_context.rendered_format = nil if options[:formats]
        lookup_context.variants = variant if variant

        view_renderer.render(view_context, options)
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