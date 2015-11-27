ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

require 'bundler/setup' # Set up gems listed in the Gemfile.

require 'module_shims'

mod_array =
  %w(
    Views::AbstractController::Rendering
    Views::ActionView::ViewPaths
    Views::ActionView::Rendering
    Views::ActionView::Layouts
    Views::ActionController::Rendering
    Views::ActionController::Renderers

    Views::ActionView::LookupContext::ViewPaths

    Views::ActionView::Renderer
  )

mod_hash = {
  'Views::ActionView::LookupContext::ViewPaths' => 'app/source/views/action_view'
}

trace = TracePoint.new(:class) do |tp|
  src_mod = mod_array.find { |src| tp.self.name == src.gsub(/\A[^:]+::/, '') }

  if src_mod
    mod_hash[src_mod] && require(File.expand_path("../../#{mod_hash[src_mod]}", __FILE__))
    src_mod.constantize.insert_shim
  end
end

trace.enable