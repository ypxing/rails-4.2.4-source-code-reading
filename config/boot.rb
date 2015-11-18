ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

trace = TracePoint.new(:class) do |tp|
	src_mod =
	  %w(
	  	Views::AbstractController::Rendering
	  	Views::ActionController::Rendering
	  	Views::ActionController::Renderers
	  ).find { |src| tp.self.name == src.gsub(/\A[^:]+::/, '') }

	src_mod.constantize.insert if src_mod
end

trace.enable