require "date"
require "yaml"

module Docs
  class Document
    attr_reader :slug, :title, :summary, :last_updated, :category, :content

    def self.from_file(path, renderer: MarkdownRenderer.new)
      raw = File.read(path)
      front_matter, body = extract_front_matter(raw)
      return nil if front_matter.nil?

      metadata = front_matter || {}

      slug = File.basename(path, ".md")
      title = metadata.fetch("title", slug.tr("-", " ").titleize)
      summary = metadata.fetch("summary", "")
      last_updated = metadata.fetch("last_updated", "")
      category = metadata.fetch("category", "Other")

      new(
        slug: slug,
        title: title,
        summary: summary,
        last_updated: last_updated,
        category: category,
        content: body,
        renderer: renderer
      )
    end

    def initialize(slug:, title:, summary:, last_updated:, category:, content:, renderer: MarkdownRenderer.new)
      @slug = slug
      @title = title
      @summary = summary
      @last_updated = last_updated
      @category = category
      @content = content
      @renderer = renderer
    end

    def html
      @html ||= @renderer.render(content)
    end

    def search_blob
      [title, summary, content].join(" ")
    end

    def last_updated_label
      return "" if last_updated.blank?

      Date.parse(last_updated.to_s).strftime("%B %-d, %Y")
    rescue Date::Error
      last_updated.to_s
    end

    def self.extract_front_matter(raw)
      return [nil, raw] unless raw.start_with?("---")

      match = raw.match(/\A---\s*\n(.*?)\n---\s*\n/m)
      return [nil, raw] unless match

      front_matter = YAML.safe_load(match[1], permitted_classes: [Date], aliases: true) || {}
      body = raw.sub(match[0], "")
      [front_matter, body]
    end
  end
end
