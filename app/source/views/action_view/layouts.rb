module Views
  module ActionView
    module Layouts
      extend ModuleSwitch

      def _normalize_options(options) # :nodoc:
        super

        if _include_layout?(options)
          layout = options.delete(:layout) { :default }
          options[:layout] = _layout_for_option(layout)
        end
      end

      # when layout should be used
      def _include_layout?(options)
        (options.keys & [:body, :text, :plain, :html, :inline, :partial]).empty? || options.key?(:layout)
      end

      # from options[:layout] of "render" method
      # in most cases, Proc.new { _default_layout(false) } will be returned
      # this proc will be used in ::ActionView::TemplateRenderer to resolve_layout
      def _layout_for_option(name)
        case name
        when String     then _normalize_layout(name)
        when Proc       then name
        when true       then Proc.new { _default_layout(true)  } # layout is required. raise error if cannot find layout
        when :default   then Proc.new { _default_layout(false) } # most case, default is used
        when false, nil then nil
        else
          raise ArgumentError,
            "String, Proc, :default, true, or false, expected for `layout'; you passed #{name.inspect}"
        end
      end

      # Returns the default layout for this controller.
      # Optionally raises an exception if the layout could not be found.
      #
      # ==== Parameters
      # * <tt>require_layout</tt> - If set to true and layout is not found,
      #   an ArgumentError exception is raised (defaults to false)
      #
      # ==== Returns
      # * <tt>template</tt> - The template object for the default layout (or nil)
      def _default_layout(require_layout = false)
        begin

          # action_has_layout?
          # Controls whether an action should be rendered using a layout.
          # If you want to disable any <tt>layout</tt> settings for the
          # current action so that it is rendered without a layout then
          # either override this method in your controller to return false
          # for that action or set the <tt>action_has_layout</tt> attribute
          # to false before rendering.

          # _layout
          # defined by _write_layout_method
          # each controller can define it's own _layout
          # by default, it will "lookup_context.find_all('#{_implied_layout_name}', #{prefixes.inspect}).first || super"
          # _implied_layout_name is "controller_path" (e.g. "users") and prefixes is like ["layouts"]

          value = _layout if action_has_layout?
        rescue NameError => e
          raise e, "Could not render layout: #{e.message}"
        end

        if require_layout && action_has_layout? && !value
          raise ArgumentError,
            "There was no default layout for #{self.class} in #{view_paths.inspect}"
        end

        # make "value" start with "layouts" if "value" is a String
        # "application" should become to "layouts/application"
        _normalize_layout(value)
      end

      # # this method should be created by _write_layout_method
      # # below is just one example (used by most cases)
      # #
      # # each class (like UsersController) inherited from ActionController::Base
      # # will call _write_layout_method to create its own private _layout method
      # def _layout
      #   implied_layout_name = self.class.send(:_implied_layout_name)
      #   prefixes    = implied_layout_name =~ /\blayouts/ ? [] : ["layouts"]
      #   # super here should be _layout defined in ancestors of controller.class

      #   # 0. prefixes would be like ["layouts"]
      #   # 1. implied_layout_name would be like "users" for UsersController
      #   # 2. it would be "application" for ApplicationController
      #   lookup_context.find_all(implied_layout_name, prefixes).first || super
      # end
    end
  end
end