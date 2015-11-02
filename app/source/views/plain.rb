module Views
	module Plain

		# *options may be
		# (1) :show, { ... } (will be changed to { action: :show, ... } by AbstractController::Rendering#_normalize_args)
		# (2) { ... }
    def render *options, &block
      controller.render *options, &block
    end
	end
end