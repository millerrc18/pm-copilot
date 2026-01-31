namespace :docs do
  desc "Build static HTML documentation in public/docs"
  task build: :environment do
    Docs::HtmlExporter.new.export
    puts "Docs exported to public/docs"
  end

  desc "Check documentation links for missing files"
  task check_links: :environment do
    docs = Docs::Repository.all
    slugs = docs.map(&:slug)
    issues = []

    docs.each do |doc|
      doc.content.scan(/\[[^\]]+\]\(([^\)]+)\)/).flatten.each do |link|
        next if link.start_with?("http", "https", "mailto", "tel", "#")

        if link.start_with?("/docs/")
          slug = link.split("/docs/").last.split(/[?#]/).first
          issues << "Missing docs slug #{slug} referenced in #{doc.slug}" unless slugs.include?(slug)
        elsif link.end_with?(".md")
          path = Rails.root.join("docs", link).cleanpath
          issues << "Missing file #{link} referenced in #{doc.slug}" unless path.exist?
        elsif link.start_with?("docs/")
          path = Rails.root.join(link).cleanpath
          issues << "Missing file #{link} referenced in #{doc.slug}" unless path.exist?
        end
      end
    end

    if issues.any?
      issues.each { |issue| warn issue }
      abort "Documentation link check failed"
    else
      puts "Documentation links look good"
    end
  end
end
