module Views
	module ActionView
		module Renderer
			# ::ActionView::Renderer::TemplateRender is one class in Rails
			module TemplateRenderer

				def self.included(mod)
					mod.remove_existing_instance_methods(self)
				end

		    def render(context, options)
		      @view    = context
		      # get info [:locale, :formats, :variants, :handlers]
		      @details = extract_details(options)

		      template = determine_template(options)

		      # add template.formats to @looup_context.formats
		      prepend_formats(template.formats)
		      # set the first format as "rendered_format"
		      @lookup_context.rendered_format ||= (template.formats.first || formats.first)

		      # options[:layout] should have been set in _normalize_options of action_view/layouts.rb.
		      # it would look like Proc.new { _default_layout(false) } 
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

		    # def initialize(lookup_context)
		    #   @lookup_context = lookup_context
		    # end

		    protected

		    # This is in abstract_renderer
		    # def extract_details(options)
		    # 	# @lookup_context.registered_details: [:locale, :formats, :variants, :handlers]
		    #   @lookup_context.registered_details.each_with_object({}) do |key, details|
		    #     value = options[key]

		    #     details[key] = Array(value) if value
		    #   end
		    # end

		    # Renders the given template. A string representing the layout can be
		    # supplied as well.
		    def render_template(template, layout_name = nil, locals = nil) #:nodoc:
		      view, locals = @view, locals || {}

		      render_with_layout(layout_name, locals) do |layout|
		        instrument(:template, :identifier => template.identifier, :layout => layout.try(:virtual_path)) do

		        	# template is one instance of ::ActionView::Template
		        	# it's the template for like "app/views/users/show.html.erb"
		        	# view is view_context.
		          template.render(view, locals) { |*name| view._layout_for(*name) }
		        end
		      end
		    end

		    def render_with_layout(path, locals) #:nodoc:
		    	# find_layout will trigger finding ::ActionView::Template for "layout"
		      layout  = path && find_layout(path, locals.keys)
		      content = yield(layout)

		      if layout
		        view = @view
		        view.view_flow.set(:layout, content)
		        layout.render(view, locals){ |*name| view._layout_for(*name) }
		      else
		        content
		      end
		    end

		    # This is the method which actually finds the layout using details in the lookup
		    # context object. If no layout is found, it checks if at least a layout with
		    # the given name exists across all details before raising the error.
		    def find_layout(layout, keys)
		      with_layout_format { resolve_layout(layout, keys) }
		    end

		    def resolve_layout(layout, keys)
		      case layout
		      when String
		        begin
		          if layout =~ /^\//
		            with_fallbacks { find_template(layout, nil, false, keys, @details) }
		          else
		          	# use the same way to find layout if it's still one String.
		            find_template(layout, nil, false, keys, @details)
		          end
		        rescue ActionView::MissingTemplate
		          all_details = @details.merge(:formats => @lookup_context.default_formats)
		          raise unless template_exists?(layout, nil, false, keys, all_details)
		        end
		      when Proc
		      	# this is the most used case.
		      	# layout would be one proc defined in ::ActionView::Layouts
		      	# like Proc.new { _default_layout(false) }

		      	# layout.call will resolve one ::ActionView::Template as "layout"
		        resolve_layout(layout.call, keys)
		      when FalseClass
		        nil
		      else
		        layout
		      end
		    end

		    ::ActionView::TemplateRenderer.send(:include, self)
			end
		end
	end
end