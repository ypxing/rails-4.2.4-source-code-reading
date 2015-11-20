# lib/action_view/view_paths.rb
module Views
  module ActionView
    module ViewPaths
      extend ModuleShims::Switch

      # irb(main):027:0> controller._prefixes
      # => ["users", "application"]
      # irb(main):028:0> controller.details_for_lookup
      # => {}
      def lookup_context
        @_lookup_context ||=
          ::ActionView::LookupContext.new(self.class._view_paths, details_for_lookup, _prefixes)
      end
    end
  end
end