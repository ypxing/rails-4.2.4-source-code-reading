module Views
  module ActionView
    module Template
      module Handlers
        # ::ActionView::Template::Handlers
        module ERB
          extend ModuleSwitch

          def self.prepended(mod)
            mod.class_eval do
              # class_attribute :erb_trim_mode
              self.erb_trim_mode = '-'

              # Default implementation used.
              # class_attribute :erb_implementation
              # self.erb_implementation = Erubis
              self.erb_implementation = ::ActionView::Template::Handlers::Erubis

              # Do not escape templates of these mime types.
              # class_attribute :escape_whitelist

              # since Rails 4.2, output between <% %> will be escaped
              # this should tell when escaping is not needed.
              self.escape_whitelist = ["text/plain"]
            end

            super
          end

          def call(template)
            # First, convert to BINARY, so in case the encoding is
            # wrong, we can still find an encoding tag
            # (<%# encoding %>) inside the String using a regular
            # expression
            template_source = template.source.dup.force_encoding(Encoding::ASCII_8BIT)

            erb = template_source.gsub(::ActionView::Template::Handlers::ERB::ENCODING_TAG, '')
            encoding = $2

            erb.force_encoding valid_encoding(template.source.dup, encoding)

            # Always make sure we return a String in the default_internal
            erb.encode!

            self.class.erb_implementation.new(
              erb,
              :escape => (self.class.escape_whitelist.include? template.type),
              :trim => (self.class.erb_trim_mode == "-")
            ).src
          end
        end
      end
    end
  end
end