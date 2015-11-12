module Views
	module ActionView
		# ::ActionView::Template is one class in Rails
		module Template
			include Views::ActionView::ViewPaths

			def self.extended(mod)
				::ActionView::Template.send(:include, ::Views::ActionView::Template)
			end

			def self.included(mod)
				mod.remove_existing_instance_methods(self)
			end
		end
	end
end