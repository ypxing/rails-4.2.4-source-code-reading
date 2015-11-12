module Views
	module ActionView
		module Renderer
			class TemplateRenderer# < ::ActionView::AbstractRenderer

		    def render(context, options)
		      @view    = context
		      # get info [:locale, :formats, :variants, :handlers]
		      @details = extract_details(options)

		      template = determine_template(options)

		      # add template.formats to @looup_context.formats
		      prepend_formats(template.formats)
		      # set the first format as "rendered_format"
		      @lookup_context.rendered_format ||= (template.formats.first || formats.first)

		      render_template(template, options[:layout], options[:locals])
		    end

		    # Determine the template to be rendered using the given options.
		    # 1. render text: ...
		    # 2. render :show (should have been converted to render template: :show)
		    def determine_template(options)

		    	# keys are for local variables passed to template
		      keys = options.has_key?(:locals) ? options[:locals].keys : []

		      if options.key?(:body)
		        ::ActionView::Template::Text.new(options[:body])
		      elsif options.key?(:text)
		        ::ActionView::Template::Text.new(options[:text], formats.first)
		      elsif options.key?(:plain)
		        ::ActionView::Template::Text.new(options[:plain])
		      elsif options.key?(:html)
		        ::ActionView::Template::HTML.new(options[:html], formats.first)
		      elsif options.key?(:file)
		        with_fallbacks { find_template(options[:file], nil, false, keys, @details) }
		      elsif options.key?(:inline)
		        handler = ::ActionView::Template.handler_for_extension(options[:type] || "erb")
		        ::ActionView::Template.new(options[:inline], "inline template", handler, :locals => keys)
		      elsif options.key?(:template)
		        if options[:template].respond_to?(:render)
		          options[:template]
		        else
		        	# for most cases, you should be here
		          find_template(options[:template], options[:prefixes], false, keys, @details)
		        end
		      else
		        raise ArgumentError, "You invoked render but did not give any of :partial, :template, :inline, :file, :plain, :text or :body option."
		      end
		    end

		    # below is in ::ActionView::AbstractRenderer
		    delegate :find_template, :template_exists?, :with_fallbacks, :with_layout_format, :formats, :to => :@lookup_context

		    def initialize(lookup_context)
		      @lookup_context = lookup_context
		    end

		    protected

		    def extract_details(options)
		    	# @lookup_context.registered_details: [:locale, :formats, :variants, :handlers]
		      @lookup_context.registered_details.each_with_object({}) do |key, details|
		        value = options[key]

		        details[key] = Array(value) if value
		      end
		    end

		    def instrument(name, options={})
		      ActiveSupport::Notifications.instrument("render_#{name}.action_view", options){ yield }
		    end

		    def prepend_formats(formats)
		      formats = Array(formats)
		      return if formats.empty? || @lookup_context.html_fallback_for_js

		      @lookup_context.formats = formats | @lookup_context.formats
		    end
			end
		end
	end
end