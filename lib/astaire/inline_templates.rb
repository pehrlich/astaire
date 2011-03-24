module Astaire
  class InlineTemplates < ActionView::PathResolver
    def initialize
      super
      @templates = {}
    end

    def add_controller(controller)
      file = caller_files.first

      begin
        app, data =
          ::IO.read(file).gsub("\r\n", "\n").split(/^__END__$/, 2)
      rescue Errno::ENOENT
        app, data = nil
      end

      if data
        lines = app.count("\n") + 1
        template = nil
        data.each_line do |line|
          lines += 1
          if line =~ /^@@\s*(.*)/
            template = ''
            @templates["#{controller.controller_path}/#{$1}"] =
              [template, file, lines]
          elsif template
            template << line
          end
        end
      end
    end

    def query(path, exts, formats)
      query = Regexp.escape(path)
      exts.each do |ext|
        query << '(' << ext.map {|e| e && Regexp.escape(".#{e}") }.join('|') << '|)'
      end

      templates = []
      @templates.select { |k,v| k =~ /^#{query}$/ }.each do |path, (source, file, lines)|
        handler, format = extract_handler_and_format(path, formats)
        templates << ActionView::Template.new(source, path, handler,
          :virtual_path => path, :format => format)
      end

      templates.sort_by {|t| -t.identifier.match(/^#{query}$/).captures.reject(&:blank?).size }
    end

    # Like Kernel#caller but excluding certain magic entries and without
    # line / method information; the resulting array contains filenames only.
    def caller_files
      caller_locations.
        map { |file,line| file }
    end

    def caller_locations
      caller(1).
        map    { |line| line.split(/:(?=\d|in )/)[0,2] }.
        reject { |file,line| Astaire::CALLERS_TO_IGNORE.any? { |pattern| file =~ pattern } }
    end
  end
end