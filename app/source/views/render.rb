module Views

  class Render

    attr_reader :controller

    # "users"
    # set "action_name" if you need use action_name helper in view
    def initialize(controller_name, request = nil, action_name = nil)
      @controller = "#{controller_name.capitalize}Controller".constantize.new

      controller.action_name = action_name
      controller.request = request ||
          ActionDispatch::Request.new({"rack.methodoverride.original_method" => "GET"})

      controller.send(:set_response!, controller.request)
    end

    # *options may be
    # (1) :show, { ... } (will be changed to { action: :show, ... } by AbstractController::Rendering#_normalize_args)
    # (2) { ... }

    # will be in Views::AbstractController::Rendering
    def render *options, &block
      controller.render *options, &block
    end
  end
end
