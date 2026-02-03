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

      needles = query.downcase.split(/\s+/).reject(&:blank?)
      return [] if needles.empty?

      results = all.map do |doc|
        score = score_document(doc, needles)
        [ doc, score ]
      end

      results
        .select { |_, score| score.positive? }
        .sort_by { |doc, score| [ -score, doc.title ] }
        .map(&:first)
    end

    def self.load_all
      Dir.glob(DOCS_PATH.join("*.md")).sort.map do |path|
        Document.from_file(path)
      end.compact
    end

    def self.score_document(doc, needles)
      title = doc.title.downcase
      summary = doc.summary.downcase
      content = doc.content.downcase

      needles.sum do |needle|
        score = 0
        score += 5 if title.include?(needle)
        score += 3 if summary.include?(needle)
        score += 1 if content.include?(needle)
        score
      end
    end
  end
end
