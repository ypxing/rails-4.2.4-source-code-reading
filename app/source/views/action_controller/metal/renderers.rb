module Views
  module ActionController
    module Renderers
      extend ModuleShims::Switch

      def render_to_body(options)
        # 1. _render_to_body_with_renderer(options) is for render json: ... (or :js, :xml, customized format)
        # 2. super is for render :show (most normal case)
        _render_to_body_with_renderer(options) || super
      end

      def _render_to_body_with_renderer(options)
        # check :json, :xml, :js or customized format; #<Set: {:json, :js, :xml}>
        _renderers.each do |name|
          if options.key?(name)
            # defined in Views::AbstractController::Rendering
            _process_options(options)

            # "_render_with_renderer_json" for render json: ...
            method_name = ::ActionController::Renderers._render_with_renderer_method_name(name)

            # call "_render_with_renderer_json" for render json: ...
            return send(method_name, options.delete(name), options)
          end
        end

        # let super's render_to_body handle it
        nil
      end

    end
  end
end