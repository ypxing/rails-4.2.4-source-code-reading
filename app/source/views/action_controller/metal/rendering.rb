module Views
	module ActionController
		module Rendering
      extend ModuleSwitch

      # Check for double render errors and set the content_type after rendering.
      def render(*args) #:nodoc:
        byebug
        # raise ::AbstractController::DoubleRenderError if response_body
        # super
        super_method(__callee__, *args)
      end

      def _normalize_text(options)
        # RENDER_FORMATS_IN_PRIORITY = [:body, :text, :plain, :html]
        ::ActionController::Rendering::RENDER_FORMATS_IN_PRIORITY.each do |format|
          if options.key?(format) && options[format].respond_to?(:to_text)
            options[format] = options[format].to_text
          end
        end
      end

      def render_to_body(options = {})
        super_method(__callee__, options) || _render_in_priorities(options) || ' '
      end

      private

      def _render_in_priorities(options)
        RENDER_FORMATS_IN_PRIORITY.each do |format|
          return options[format] if options.key?(format)
        end

        nil
      end

      # Normalize arguments by catching blocks and setting them on :update.
      def _normalize_args(action=nil, options={}, &blk) #:nodoc:
        # options = super
        options = super_method(__callee__, action, options, &blk)
        options[:update] = blk if block_given?
        options
      end

      # Normalize both text and status options.
      def _normalize_options(options) #:nodoc:
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

        # super
        super_method(__callee__, options)
      end

      # Process controller specific options, as status, content-type and location.
      def _process_options(options) #:nodoc:
        status, content_type, location = options.values_at(:status, :content_type, :location)

        self.status = status if status
        self.content_type = content_type if content_type
        self.headers["Location"] = url_for(location) if location

        # super
        super_method(__callee__, options)
      end

      def _process_format(format, options = {})
        # super
        super_method(__callee__, format, options)
        if options[:plain]
          self.content_type = Mime::TEXT
        else
          self.content_type ||= format.to_s
        end
      end

		end
	end
end