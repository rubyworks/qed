require 'rdoc/markup/simple_markup'
require 'rdoc/markup/simple_markup/to_html'

module QED
class Document

  # = QED Document Markup
  #
  # QED Document Markup is based on RDoc's SimpleMarkup format but adds
  # some additional features.
  #
  # * `[no-spaces]` produces <code>[no-space]</code>.
  #
  class Markup

    def initialize(text, options={})
      @text = text
    end

    def to_html
      parser.convert(@text, formatter)
    end

    def parser
      @parser ||= (
        p = SM::SimpleMarkup.new
        #p.add_word_pair("{", "}", :STRIKE)
        #p.add_html("no", :STRIKE)
        #p.add_special(/\b([A-Z][a-z]+[A-Z]\w+)/, :WIKIWORD)
        p.add_special(/\`(\S+?)\`/, :CODE)
        p
      )
    end

    def formatter
      @formatter ||= (
        f = ToHTML.new
        #f.add_tag(:STRIKE, "<strike>", "</strike>")
        f
      )
    end

    # Formatter
    class ToHTML < SM::ToHtml
      def handle_special_CODE(special)
        "<code>" + special.text.sub('`','').chomp('`') + "</code>"
      end
    end

  end

end
end
