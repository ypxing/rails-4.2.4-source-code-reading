module Views
  class Render
    # include ActiveSupport::Callbacks
    # define_callbacks :render
    # set_callback :render, :before, :prepare

    attr_reader :controller#, :options

    # "users"
    # set "action_name" if you need use action_name helper in view
    def initialize(controller_name, request = nil, action_name = nil)
      @controller = "#{controller_name.capitalize}Controller".constantize.new

      controller.action_name = action_name
      controller.request = request ||
          ActionDispatch::Request.new({"rack.methodoverride.original_method" => "GET"})

      controller.send(:set_response!, controller.request)

      # temp
      controller.instance_variable_set(:@count, 1)
    end

    # def render(options, &block)
    #   @options = options

    #   run_callbacks :render do
    #     _render &block
    #   end
    # end
  end
end
