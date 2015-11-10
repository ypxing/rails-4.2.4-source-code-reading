module Views
	module ActionController
    module Metal
  		module Rendering
        include Views::AbstractController::Rendering

        def _normalize_text(options)
          # RENDER_FORMATS_IN_PRIORITY = [:body, :text, :plain, :html]
          ::ActionController::Rendering::RENDER_FORMATS_IN_PRIORITY.each do |format|
            if options.key?(format) && options[format].respond_to?(:to_text)
              options[format] = options[format].to_text
            end
          end
        end

  		end
    end
	end
end