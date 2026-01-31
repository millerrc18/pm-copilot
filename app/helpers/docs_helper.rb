module DocsHelper
  ALLOWED_TAGS = %w[
    a
    blockquote
    br
    code
    div
    em
    h1
    h2
    h3
    h4
    h5
    h6
    hr
    img
    li
    ol
    p
    pre
    span
    strong
    table
    tbody
    td
    th
    thead
    tr
    ul
  ].freeze

  ALLOWED_ATTRIBUTES = %w[href src alt title class].freeze

  def docs_sanitize(html)
    sanitize(html, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
  end
end
