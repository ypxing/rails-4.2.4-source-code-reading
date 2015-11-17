module Views
	module ActionView
		# ::ActionView::PathSet is one Class in Rails
		module PathSet
			extend ModuleSwitch

			# default view_paths
			# 1. railties/lib/rails/application_controller.rb
			# self.view_paths = File.expand_path('../templates', __FILE__)
			# 2. railities/lib/rails/engine.rb
	    # initializer :add_view_paths do
	    #   # will return absolte paths
	    #   views = paths["app/views"].existent
	    #   unless views.empty?
	    #     ActiveSupport.on_load(:action_controller){ prepend_view_path(views) if respond_to?(:prepend_view_path) }
	    #     ActiveSupport.on_load(:action_mailer){ prepend_view_path(views) }
	    #   end
	    # end
	    # you have below as view_paths by default
	    # railties-4.2.4/lib/rails/templates (should be full path)
	    # app/views

			# just from ::ActionView::PathSet
			# each path will be converted to one OptimizedFileSystemResolver
	    # def initialize(paths = [])
	    #   @paths = typecast paths
	    # end

	    def find(*args)
	      find_all(*args).first || raise(MissingTemplate.new(self, *args))
	    end

	    # path: like "show"
	    # prefixes: like ["users", "application"]
	    def find_all(path, prefixes = [], *args)
	      prefixes = [prefixes] if String === prefixes
	      prefixes.each do |prefix|
	      	# paths include the related OptimizedFileSystemResolver
	        paths.each do |resolver|
	        	# find "show" under prefix like "users"
	          templates = resolver.find_all(path, prefix, *args)
	          return templates unless templates.empty?
	        end
	      end
	      []
	    end

	    private

	    def typecast(paths)
	      paths.map do |path|
	        case path
	        when Pathname, String
	        	# so each path has been coverted to one OptimizedFileSystemResolver
	          ::ActionView::OptimizedFileSystemResolver.new path.to_s
	        else
	          path
	        end
	      end
	    end
		end
	end
end