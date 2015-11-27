require_relative './action_view/lookup_context'

module Views
	module ActionView
		extend ActiveSupport::Autoload

    autoload_under "renderer" do
      autoload :Renderer
      autoload :TemplateRenderer
    end

    autoload_at "views/action_view/template/resolver" do
      autoload :OptimizedFileSystemResolver
    end
	end
end