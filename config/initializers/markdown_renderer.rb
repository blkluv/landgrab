# frozen_string_literal: true

# https://stackoverflow.com/a/68098687/1323144
module MarkdownRenderer
  YOUTUBE_REGEX = %r{^(?:https?:)?(?://)?(?:youtu\.be/|(?:www\.|m\.)?youtube\.com/(?:watch|v|embed)(?:\.php)?(?:\?.*v=|/))([a-zA-Z0-9_-]{7,15})(?:[?&][a-zA-Z0-9_-]+=[a-zA-Z0-9_-]+)*$}

  class CustomRenderer < Redcarpet::Render::HTML
    def block_quote(quote)
      %(<blockquote class="blockquote">#{quote}</blockquote>)
    end

    def table(header, body)
      "<table class=\"table\">#{header}#{body}</table>"
    end

    def image(link, title, alt_text)
      %(<image src="#{link}" title="#{title}" alt="#{alt_text}" class="rounded img-fluid" />)
    end

    def autolink(link, link_type)
      case link_type
      when :url then url_link(link)
      when :email then email_link(link)
      else raise "Unexpected link_type: #{link_type}"
      end
    end

    def url_link(link)
      slug = link.scan(YOUTUBE_REGEX).last&.first
      return youtube_embed(slug) if slug.present?

      normal_link(link)
    end

    def youtube_embed(slug)
      <<-HTML
        <div class="ratio ratio-16x9">
          <iframe width="560" height="315"
                  src="https://www.youtube.com/embed/#{slug}"
                  title="Video"
                  frameborder="0"
                  allow="accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                  allowfullscreen></iframe>
        </div>
      HTML
    end

    def normal_link(link)
      "<a href=\"#{link}\">#{link}</a>"
    end

    def email_link(email)
      "<a href=\"mailto:#{email}\">#{email}</a>"
    end
  end

  def self.markdown
    # rubocop:disable Style/ClassVars
    @@markdown ||= Redcarpet::Markdown.new(
      renderer,
      autolink: true,
      fenced_code_blocks: true,
      no_intra_emphasis: true,
      space_after_headers: true,
      tables: true
    )
    # rubocop:enable Style/ClassVars
  end

  def self.renderer
    CustomRenderer.new(
      escape_html: false,
      hard_wrap: true,
      safe_links_only: true
    )
  end

  def self.render(text)
    markdown.render(text)
  end
end
