ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

trace = TracePoint.new(:class) do |tp|
  src_mod =
    %w(
      Views::AbstractController::Rendering
      Views::ActionView::ViewPaths
      Views::ActionView::Rendering
      Views::ActionView::Layouts
      Views::ActionController::Rendering
      Views::ActionController::Renderers

      Views::ActionView::Renderer
    ).find { |src| tp.self.name == src.gsub(/\A[^:]+::/, '') }

  src_mod.constantize.insert_shim if src_mod
end

trace.enable