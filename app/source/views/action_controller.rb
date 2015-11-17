module Views
	module ActionController
		extend ActiveSupport::Autoload

	  autoload_under "metal" do
	    autoload :Renderers
	    autoload :Rendering
	  end
	end
end