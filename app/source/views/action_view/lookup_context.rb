module Views
	module ActionView
		# make it class just because it's one class in Rails
		module LookupContext
			module ViewPaths
				# TemplateRender will call find_template which has been delegated to lookup_context.
				# lookup_context includes module ::ActionView::LookupContext::ViewPaths.
				# name: "show"
				# prefixes: ["users", "application"]
				# partial: false
				# keys: []. used to pass local variables to template
				# options: {}. for any of [:locale, :formats, :variants, :handlers]
	      def find(name, prefixes = [], partial = false, keys = [], options = {})
	        @view_paths.find(*args_for_lookup(name, prefixes, partial, keys, options))
	      end

				alias :find_template :find

		    protected

	      def args_for_lookup(name, prefixes, partial, keys, details_options) #:nodoc:
	      	# if name is like "a/b/c"
	      	# after normalization, it will be "c" and "a/b" will be appended to each of prefixes
	        name, prefixes = normalize_name(name, prefixes)

	        details, details_key = detail_args_for(details_options)
	        [name, prefixes, partial || false, details, details_key, keys]
	      end

	      # Compute details hash and key according to user options (e.g. passed from #render).
	      # default "details":
	      # default_formats: ::ActionView::Base.default_formats || [:html, :text, :js, :css,  :xml, :json]
	      # default_variants: []
	      # default_handlers: ::ActionView::Template::Handlers.extensions
	      # deault_locale: [:en] (after calculation ;))
	      def detail_args_for(options)
	      	# for most plain case, you may not provide any of [:locale, :formats, :variants, :handlers]
	      	# it will return here
	        return @details, details_key if options.empty?

	        # merge details with "details" provided by "user"
	        user_details = @details.merge(options)

	        if @cache
	          details_key = DetailsKey.get(user_details)
	        else
	          details_key = nil
	        end

	        [user_details, details_key]
	      end

	      # Support legacy foo.erb names even though we now ignore .erb
	      # as well as incorrectly putting part of the path in the template
	      # name instead of the prefix.
	      def normalize_name(name, prefixes) #:nodoc:
	        prefixes = prefixes.presence
	        parts    = name.to_s.split('/')
	        parts.shift if parts.first.empty?
	        name     = parts.pop

	        # return here if name is just like "show"
	        return name, prefixes || [""] if parts.empty?

	        # otherwise, change prefixes
	        parts    = parts.join('/')
	        prefixes = prefixes ? prefixes.map { |p| "#{p}/#{parts}" } : [parts]

	        # for input "my/show", ["users", "application"]
	        # it would become
	        # "show", ["users/my", "application/my"]
	        return name, prefixes
	      end

		    ::ActionView::LookupContext.send(:include, self)
			end
		end
	end
end