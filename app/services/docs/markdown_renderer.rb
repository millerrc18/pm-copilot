module Docs
  class MarkdownRenderer
    def initialize
      renderer = Redcarpet::Render::HTML.new(with_toc_data: true, hard_wrap: true)
      @markdown = Redcarpet::Markdown.new(
        renderer,
        autolink: true,
        fenced_code_blocks: true,
        lax_spacing: true,
        no_intra_emphasis: true,
        strikethrough: true,
        tables: true
      )
    end

    def render(content)
      @markdown.render(content)
    end
  end
end
