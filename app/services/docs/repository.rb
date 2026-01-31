module Docs
  class Repository
    DOCS_PATH = Rails.root.join("docs").freeze

    def self.all
      return load_all if Rails.env.development? || Rails.env.test?

      @all ||= load_all
    end

    def self.find(slug)
      all.find { |doc| doc.slug == slug }
    end

    def self.grouped_by_category
      all.group_by(&:category).sort_by { |category, _| category }
    end

    def self.search(query)
      return [] if query.blank?

      needle = query.downcase
      all.select { |doc| doc.search_blob.downcase.include?(needle) }
    end

    def self.load_all
      Dir.glob(DOCS_PATH.join("*.md")).sort.map do |path|
        Document.from_file(path)
      end.compact
    end
  end
end
