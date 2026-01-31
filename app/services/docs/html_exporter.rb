require "fileutils"

module Docs
  class HtmlExporter
    def initialize(output_dir: Rails.root.join("public/docs"))
      @output_dir = output_dir
    end

    def export
      FileUtils.rm_rf(@output_dir)
      FileUtils.mkdir_p(@output_dir)

      docs = Repository.all
      docs.each do |doc|
        write_file(@output_dir.join("#{doc.slug}.html"), wrap_html(doc.title, doc.html))
      end

      index_body = docs.map do |doc|
        "<li><a href=\"#{doc.slug}.html\">#{doc.title}</a><p>#{doc.summary}</p></li>"
      end.join
      write_file(@output_dir.join("index.html"), wrap_html("Documentation", "<ul>#{index_body}</ul>"))
    end

    private

    def wrap_html(title, body)
      <<~HTML
        <!doctype html>
        <html lang="en">
          <head>
            <meta charset="utf-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <title>#{title}</title>
            <style>
              body { font-family: Inter, system-ui, sans-serif; margin: 40px auto; max-width: 880px; color: #111827; }
              h1, h2, h3 { margin-top: 1.4em; }
              a { color: #e06469; }
              ul { padding-left: 1.2em; }
              li { margin-bottom: 1em; }
              img { max-width: 100%; border-radius: 16px; }
            </style>
          </head>
          <body>
            #{body}
          </body>
        </html>
      HTML
    end

    def write_file(path, contents)
      File.write(path, contents)
    end
  end
end
