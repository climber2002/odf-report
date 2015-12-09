module ODFReport

module Parser


  # Default HTML parser
  #
  # sample HTML
  #
  # <p> first paragraph </p>
  # <p> second <strong>paragraph</strong> </p>
  # <blockquote>
  #     <p> first <em>quote paragraph</em> </p>
  #     <p> first quote paragraph </p>
  #     <p> first quote paragraph </p>
  # </blockquote>
  # <p> third <strong>paragraph</strong> </p>
  #
  # <p style="margin: 100px"> fourth <em>paragraph</em> </p>
  # <p style="margin: 120px"> fifth paragraph </p>
  # <p> sixth <strong>paragraph</strong> </p>
  #

  class Default

    attr_accessor :paragraphs

    def initialize(text, template_node)
      @text = text
      @paragraphs = []
      @template_node = template_node

      parse
    end

    def parse

      xml = @template_node.parse(@text)

      xml.css("p", "h1", "h2").each do |p|

        style = check_style(p)
        text = parse_formatting(p.inner_html)

        add_paragraph(text, style)
      end
    end

    def add_paragraph(text, style)

      node = @template_node.dup

      node['text:style-name'] = style if style
      node.children = text

      @paragraphs << node
    end

    private

    def parse_formatting(text)
      text.strip!
      text.gsub!("&nbsp;", ' ')
      
      text.gsub!(/<strong>\s*<u>(.+?)<\/u>\s*<\/strong>/) { "<text:span text:style-name=\"boldunderline\">#{$1}<\/text:span>" }
      text.gsub!(/<u>\s*<strong>(.+?)<\/strong>\s*<\/u>/) { "<text:span text:style-name=\"boldunderline\">#{$1}<\/text:span>" }
      text.gsub!(/<strong>(.+?)<\/strong>/)  { "<text:span text:style-name=\"bold\">#{$1}<\/text:span>" }
      text.gsub!(/<em>(.+?)<\/em>/)          { "<text:span text:style-name=\"italic\">#{$1}<\/text:span>" }
      text.gsub!(/<u>(.+?)<\/u>/)            { "<text:span text:style-name=\"underline\">#{$1}<\/text:span>" }
      text.gsub!("\n", "")
      process_ul(text)
      text
    end

    # def process_ul(text)
    #   text.gsub!(/<ul>/, "<text:list text:style-name=\"L2\">")
    #   text.gsub!(/\n/, '')
    #   text.gsub!(/\r/, '')
    #   text.gsub!(/<li>(.+?)<\/li>/) { "<text:list-item><text:p text:style-name=\"P22\">#{$1}<\/text:list-item>" }
    #   text.gsub!(/<\/ul>/, "</text:list>")
    # end
    def process_ul(text)
      text.gsub!(/<ul>/, "")
      text.gsub!(/\n/, '')
      text.gsub!(/\r/, '')
      text.gsub!(/<li>(.+?)<\/li>/) { "<text:p>* #{$1}\n</text:p>" }
      text.gsub!(/<\/ul>/, "")
    end

    def check_style(node)
      style = nil

      if node.name =~ /h\d/i
        style = "title"

      elsif node.parent && node.parent.name == "blockquote"
        style = "quote"

      elsif node['style'] =~ /margin/
        style = "quote"

      end

      style
    end

  end

end

end
