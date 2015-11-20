module Views
  module ActionView
    # ::ActionView::Template is one class in Rails

    # make ERB happy.
    # the compiled "code" string will use "ActionView::OutputBuffer"
    OutputBuffer = ::ActionView::OutputBuffer

    module Template
      extend ModuleShims::Switch

      # Render a template. If the template was not compiled yet, it is done
      # exactly before rendering.
      #
      # This method is instrumented as "!render_template.action_view". Notice that
      # we use a bang in this instrumentation because you don't want to
      # consume this in production. This is only slow if it's being listened to.

      # view here is one view_context
      def render(view, locals, buffer=nil, &block)
        instrument("!render_template") do
          compile!(view)

          # call method _app_views_users_show_htm_erb__xxxxxxxx_xxxxxxxx
          view.send(method_name, locals, buffer, &block)
        end
      rescue => e
        handle_render_error(view, e)
      end

    protected

      # Compile a template. This method ensures a template is compiled
      # just once and removes the source after it is compiled.
      def compile!(view) #:nodoc:
        return if @compiled

        # Templates can be used concurrently in threaded environments
        # so compilation and any instance variable modification must
        # be synchronized
        @compile_mutex.synchronize do
          # Any thread holding this lock will be compiling the template needed
          # by the threads waiting. So re-check the @compiled flag to avoid
          # re-compilation
          return if @compiled

          # yes, view_context has included ::ActionView::CompiledTemplates
          # it's one blank module at the beginning and will be used to
          # contain all compiled template.
          if view.is_a?(::ActionView::CompiledTemplates)
            mod = ::ActionView::CompiledTemplates
          else
            mod = view.singleton_class
          end

          instrument("!compile_template") do
            compile(mod)
          end

          # Just discard the source if we have a virtual path. This
          # means we can get the template back.
          @source = nil if @virtual_path
          @compiled = true
        end
      end

      # Among other things, this method is responsible for properly setting
      # the encoding of the compiled template.
      #
      # If the template engine handles encodings, we send the encoded
      # String to the engine without further processing. This allows
      # the template engine to support additional mechanisms for
      # specifying the encoding. For instance, ERB supports <%# encoding: %>
      #
      # Otherwise, after we figure out the correct encoding, we then
      # encode the source into <tt>Encoding.default_internal</tt>.
      # In general, this means that templates will be UTF-8 inside of Rails,
      # regardless of the original source encoding.
      def compile(mod) #:nodoc:
        encode!
        method_name = self.method_name

        # code will be the ruby code compiled by handlers like ERB
        # It may include "yield". This is how partial and layout work.
        # As for handler, we can use "base.register_default_template_handler :erb, ERB.new" for example
        code = @handler.call(self)

        # Make sure that the resulting String to be eval'd is in the
        # encoding of the code

        # define the method (like _app_views_users_show_htm_erb__xxxxxxxx_xxxxxxxx)
        # #{locals_code} are the local variables passed by "locals: ..."
        # #{code} is the compiling result of one handler
        source = <<-end_src
          def #{method_name}(local_assigns, output_buffer)
            _old_virtual_path, @virtual_path = @virtual_path, #{@virtual_path.inspect};_old_output_buffer = @output_buffer;#{locals_code};#{code}
          ensure
            @virtual_path, @output_buffer = _old_virtual_path, _old_output_buffer
          end
        end_src

        # Make sure the source is in the encoding of the returned code
        source.force_encoding(code.encoding)

        # In case we get back a String from a handler that is not in
        # BINARY or the default_internal, encode it to the default_internal
        source.encode!

        # Now, validate that the source we got back from the template
        # handler is valid in the default_internal. This is for handlers
        # that handle encoding but screw up
        unless source.valid_encoding?
          raise WrongEncodingError.new(@source, Encoding.default_internal)
        end

        # define this method in mod
        # mod has been included in class of view_context
        mod.module_eval(source, identifier, 0)
        ObjectSpace.define_finalizer(self, ::ActionView::Template::Finalizer[method_name, mod])
      end

      # def handle_render_error(view, e) #:nodoc:
      #   if e.is_a?(Template::Error)
      #     e.sub_template_of(self)
      #     raise e
      #   else
      #     template = self
      #     unless template.source
      #       template = refresh(view)
      #       template.encode!
      #     end
      #     raise Template::Error.new(template, e)
      #   end
      # end

      # any local variables passed to options[:locals] will be used in the template
      # local_assigns is defined in above "def #{method_name}(local_assigns, output_buffer)"
      def locals_code #:nodoc:
        # Double assign to suppress the dreaded 'assigned but unused variable' warning
        @locals.each_with_object('') { |key, code| code << "#{key} = #{key} = local_assigns[:#{key}];" }
      end

      # that's the name you often see in the function backtrace when something goes wrong
      # it's like
      # _app_views_users_show_htm_erb__xxxxxxxx_xxxxxxxx
      def method_name #:nodoc:
        @method_name ||= begin
          m = "_#{identifier_method_name}__#{@identifier.hash}_#{__id__}"
          m.tr!('-', '_')
          m
        end
      end
    end
  end
end