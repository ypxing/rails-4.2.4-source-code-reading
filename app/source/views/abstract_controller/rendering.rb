module Views
	module AbstractController
		module Rendering
			extend ModuleSwitch

	    # Normalize arguments, options and then delegates render_to_body and
	    # sticks the result in self.response_body.
	    # :api: public
	    def render(*args, &block)
	      options = _normalize_render(*args, &block)
	      self.response_body = render_to_body(options)
	      _process_format(rendered_format, options) if rendered_format
	      self.response_body
	    end

	    # Normalize args and options.
	    # :api: private
	    def _normalize_render(*args, &block)
	      options = _normalize_args(*args, &block)
	      #TODO: remove defined? when we restore AP <=> AV dependency
	      if defined?(request) && request && request.variant.present?
	        options[:variant] = request.variant
	      end
	      _normalize_options(options)
	      options
	    end

			#<UnboundMethod: ActionController::Rendering#_normalize_args>
			#<UnboundMethod: ActionView::Rendering#_normalize_args>
			#<UnboundMethod: AbstractController::Rendering#_normalize_args>]
			# Normalize args by converting render "foo" to render :action => "foo" and
	    # render "foo/bar" to render :file => "foo/bar".
	    def _normalize_args(action=nil, options={})
	      if action.is_a? Hash
	        action
	      else
	        options
	      end
	    end

			#<UnboundMethod: ActionController::Rendering#_normalize_options>
			#<UnboundMethod: ActionView::Layouts#_normalize_options>
			#<UnboundMethod: ActionView::Rendering#_normalize_options>
			#<UnboundMethod: AbstractController::Rendering#_normalize_options>
			def _normalize_options(options)
	      options
			end

			#<UnboundMethod: ActionController::Streaming#_process_options>
			#<UnboundMethod: ActionController::Rendering#_process_options>
			#<UnboundMethod: AbstractController::Rendering#_process_options>
      def _process_options(options) #:nodoc:
        options
      end

			#<UnboundMethod: ActionController::Rendering#_process_format>
			#<UnboundMethod: ActionView::Rendering#_process_format>
			#<UnboundMethod: AbstractController::Rendering#_process_format>
      def _process_format(format, options = {})
      end

			# # one simple check
			# def _include_layout?(options)
			# 	_include_layout?(options)
			# end

			# # layout is set here
			# def _layout_for_option(layout)
			# 	_layout_for_option(layout)
			# end

			#<UnboundMethod: ActionController::Renderers#render_to_body>
			#<UnboundMethod: ActionController::Rendering#render_to_body>
			#<UnboundMethod: ActionView::Rendering#render_to_body>
			#<UnboundMethod: AbstractController::Rendering#render_to_body>
	    # Performs the actual template rendering.
	    # :api: public
	    def render_to_body(options = {})
	    end

	    def view_assigns
	    	# _protected_ivars:
		    # DEFAULT_PROTECTED_INSTANCE_VARIABLES = Set.new %w(
		    #   @_action_name @_response_body @_formats @_prefixes @_config
		    #   @_view_context_class @_view_renderer @_lookup_context
		    #   @_routes @_db_runtime
		    # ).map(&:to_sym)
	      protected_vars = _protected_ivars
	      variables      = instance_variables

	      variables.reject! { |s| protected_vars.include? s }
	      variables.each_with_object({}) { |name, hash|
	        hash[name.slice(1, name.length)] = instance_variable_get(name)
	      }
	    end

		end
	end
end