module Views
  module ActionView
    # ::ActionView::OptimizedFileSystemResolver is one class in Rails
    module OptimizedFileSystemResolver
      extend ModuleShims::Switch
      # DEFAULT_PATTERN = ":prefix/:action{.:locale,}{.:formats,}{+:variants,}{.:handlers,}"

      # Normalizes the arguments and passes it on to find_templates.
      # defined in ::ActionView::Resolver
      # name: "show"
      # prefix: ["users", "application"]
      # details: for any of [:locale, :formats, :variants, :handlers]
      # key: key of details
      # locals: keys of local variables passed to template
      def find_all(name, prefix=nil, partial=false, details={}, key=nil, locals=[])
        cached(key, [name, prefix, partial], details, locals) do
          find_templates(name, prefix, partial, details)
        end
      end

      private

      # defined in ::ActionView::PathResolver
      def find_templates(name, prefix, partial, details)
        # path is one instance of ::ActionView::Resolver::Path
        # it has one @virtual.
        # @virutal will be "#{prefix}/#{name}" if it's NOT partial
        # @virutal will be "#{prefix}/_#{name}" if it's partial
        path = ::ActionView::Resolver::Path.build(name, prefix, partial)
        query(path, details, details[:formats])
      end

      # defined in ::ActionView::PathResolver
      def query(path, details, formats)
        query = build_query(path, details)

        # query now looks like /.../app/views/users/show{.en,}{.html...
        # template_paths will be array of files in filesystem following above query.
        template_paths = find_template_paths query

        # iterate on each file
        template_paths.map { |template|
          # get handler (like ERB), format and variant from the file
          handler, format, variant = extract_handler_and_format_and_variant(template, formats)

          # read in this file
          contents = File.binread(template)

          # finally, we can use ::ActionView::Template to compile the file into Ruby code
          ::ActionView::Template.new(contents, File.expand_path(template), handler,
            :virtual_path => path.virtual,
            :format       => format,
            :variant      => variant,
            :updated_at   => mtime(template)
          )
        }
      end

      # defined in ::ActionView::OptimizedFileSystemResolver
      def build_query(path, details)
        # @path is one absolute path like "/.../app/views"
        # path.to_str will be called in File.join.
        # so query will be "/.../app/views/users/show"
        query = escape_entry(File.join(@path, path))

        # EXTENSIONS = { :locale => ".", :formats => ".", :variants => "+", :handlers => "." }
        exts = ::ActionView::PathResolver::EXTENSIONS.map do |ext, prefix|
          "{#{details[ext].compact.uniq.map { |e| "#{prefix}#{e}," }.join}}"
        end.join

        # exts would be like
        # {.en,}{.html,.text,.js,.css,.ics,.csv,.vcf,.png,.jpeg,.gif,.bmp,.tiff,.mpeg,.xml,.rss,.atom,.yaml,.multipart_form,.url_encoded_form,.json,.pdf,.zip,}{}{.erb,.builder,.raw,.ruby,.coffee,.jbuilder,}
        # so the result would be like /.../app/views/users/show{.en,}{.html...
        query + exts
      end
    end
  end
end