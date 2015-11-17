module Views
	module ActionController
    module Metal
  		module Rendering
        include Views::ActionView::Rendering

        # Check for double render errors and set the content_type after rendering.
        def render(*args) #:nodoc:
          raise ::AbstractController::DoubleRenderError if controller.response_body
          super
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
          super || _render_in_priorities(options) || ' '
        end

        private

        def _render_in_priorities(options)
          RENDER_FORMATS_IN_PRIORITY.each do |format|
            return options[format] if options.key?(format)
          end

          nil
        end

  		end
    end
	end
end