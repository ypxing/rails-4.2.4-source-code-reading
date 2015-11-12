module Views
	module AbstractController
		module Rendering

	    # # Normalize arguments, options and then delegates render_to_body and
	    # # sticks the result in self.response_body.
	    # # :api: public
	    # def render(*args, &block)
	    #   options = _normalize_render(*args, &block)
	    #   self.response_body = render_to_body(options)
	    #   _process_format(rendered_format, options) if rendered_format
	    #   self.response_body
	    # end
			def render *options, &block
	      options = _normalize_render(*options, &block)
	      controller.response_body = render_to_body(options)
	      controller.send(:_process_format, controller.rendered_format, options) if controller.rendered_format
	      controller.response_body
			end

	    # # Normalize args and options.
	    # # :api: private
	    # def _normalize_render(*args, &block)
	    #   options = _normalize_args(*args, &block)
	    #   #TODO: remove defined? when we restore AP <=> AV dependency
	    #   if defined?(request) && request && request.variant.present?
	    #     options[:variant] = request.variant
	    #   end
	    #   _normalize_options(options)
	    #   options
	    # end
			def _normalize_render(*options, &block)
	      options = _normalize_args(*options, &block)
	      #TODO: remove defined? when we restore AP <=> AV dependency
	      if defined?(controller.request) && controller.request && controller.request.variant.present?
	        options[:variant] = controller.request.variant
	      end
	      # controller.send(:_normalize_options, options)
	      _normalize_options(options)
	      options
			end

			#<UnboundMethod: ActionController::Rendering#_normalize_args>
			#<UnboundMethod: ActionView::Rendering#_normalize_args>
			#<UnboundMethod: AbstractController::Rendering#_normalize_args>]
			def _normalize_args(action=nil, options={}, &blk)
		    # Normalize args by converting render "foo" to render :action => "foo" and
		    # render "foo/bar" to render :file => "foo/bar".
		    options = if action.is_a? Hash
						        action
						      else
						        options
						      end

				# action_view/rendering.rb 113
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

				# action_controller/metal/rendering.rb 34
		    options[:update] = blk if block_given?
		    options
			end

			#<UnboundMethod: ActionController::Rendering#_normalize_options>
			#<UnboundMethod: ActionView::Layouts#_normalize_options>
			#<UnboundMethod: ActionView::Rendering#_normalize_options>
			#<UnboundMethod: AbstractController::Rendering#_normalize_options>
			def _normalize_options(options)
				# action_controller/metal/rendering.rb 63
				# action_controller/metal/rendering.rb 81
				# ENDER_FORMATS_IN_PRIORITY = [:body, :text, :plain, :html]
				# It's to call options[format]#to_text if possible for the given formats
	      ::ActionController::Rendering::RENDER_FORMATS_IN_PRIORITY.each do |format|
	        if options.key?(format) && options[format].respond_to?(:to_text)
	          options[format] = options[format].to_text
	        end
	      end

	      if options[:html]
	        options[:html] = ERB::Util.html_escape(options[:html])
	      end

	      if options.delete(:nothing)
	        options[:body] = nil
	      end

	      if options[:status]
	        options[:status] = Rack::Utils.status_code(options[:status])
	      end

				# action_view/rendering.rb      132
        if options[:partial] == true
          options[:partial] = controller.action_name
        end

        if (options.keys & [:partial, :file, :template]).empty?
          options[:prefixes] ||= controller._prefixes
        end

        # this is why you don't need to set action
        options[:template] ||= (options[:action] || controller.action_name).to_s

        # action_view/layouts.rb          342
	      if _include_layout?(options)
	        layout = options.delete(:layout) { :default }
	        options[:layout] = _layout_for_option(layout)
	      end

			end

			#<UnboundMethod: ActionController::Streaming#_process_options>
			#<UnboundMethod: ActionController::Rendering#_process_options>
			#<UnboundMethod: AbstractController::Rendering#_process_options>
      def _process_options(options) #:nodoc:

      	# action_controller/metal/rendering.rb
		    _normalize_text(options)

		    if options[:html]
		      options[:html] = ERB::Util.html_escape(options[:html])
		    end

		    if options.delete(:nothing)
		      options[:body] = nil
		    end

		    if options[:status]
		      options[:status] = Rack::Utils.status_code(options[:status])
		    end

		    # action_controller/metal/streaming.rb
        if options[:stream]
          if env["HTTP_VERSION"] == "HTTP/1.0"
            options.delete(:stream)
          else
            headers["Cache-Control"] ||= "no-cache"
            headers["Transfer-Encoding"] = "chunked"
            headers.delete("Content-Length")
          end
        end
      end

			# one simple check
			def _include_layout?(options)
				controller.send(:_include_layout?, options)
			end

			# layout is set here
			def _layout_for_option(layout)
				controller.send(:_layout_for_option, layout)
			end

			#<UnboundMethod: ActionController::Renderers#render_to_body>
			#<UnboundMethod: ActionController::Rendering#render_to_body>
			#<UnboundMethod: ActionView::Rendering#render_to_body>
			#<UnboundMethod: AbstractController::Rendering#render_to_body>
			def render_to_body(options)
				controller.render_to_body(options)
			end

			# try to call to_text method of the given format (like :body, :text, :plain, :html)
			def _normalize_text(options)
				controller.send(:_normalize_text, options)
			end

	    def view_assigns
	    	# _protected_ivars:
		    # DEFAULT_PROTECTED_INSTANCE_VARIABLES = Set.new %w(
		    #   @_action_name @_response_body @_formats @_prefixes @_config
		    #   @_view_context_class @_view_renderer @_lookup_context
		    #   @_routes @_db_runtime
		    # ).map(&:to_sym)
	      protected_vars = controller._protected_ivars
	      variables      = controller.instance_variables

	      variables.reject! { |s| protected_vars.include? s }
	      variables.each_with_object({}) { |name, hash|
	        hash[name.slice(1, name.length)] = controller.instance_variable_get(name)
	      }
	    end

		end
	end
end