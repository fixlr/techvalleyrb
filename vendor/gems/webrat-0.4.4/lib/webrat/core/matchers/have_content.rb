module Webrat
  module Matchers

    class HasContent #:nodoc:
      def initialize(content)
        @content = content
      end

      def matches?(stringlike)
        if Webrat.configuration.parse_with_nokogiri?
          @document = Webrat.nokogiri_document(stringlike)
        else
          @document = Webrat.hpricot_document(stringlike)
        end

        @element = Webrat::XML.inner_text(@document)

        case @content
        when String
          @element.include?(@content)
        when Regexp
          @element.match(@content)
        end
      end

      # ==== Returns
      # String:: The failure message.
      def failure_message
        "expected the following element's content to #{content_message}:\n#{squeeze_space(@element)}"
      end

      # ==== Returns
      # String:: The failure message to be displayed in negative matches.
      def negative_failure_message
        "expected the following element's content to not #{content_message}:\n#{squeeze_space(@element)}"
      end

      def squeeze_space(inner_text)
        inner_text.gsub(/^\s*$/, "").squeeze("\n")
      end

      def content_message
        case @content
        when String
          "include \"#{@content}\""
        when Regexp
          "match #{@content.inspect}"
        end
      end
    end

    # Matches the contents of an HTML document with
    # whatever string is supplied
    def contain(content)
      HasContent.new(content)
    end

    # Asserts that the stringlike object (or body of the response) contain
    # the supplied string or regexp
    def assert_contain(content, stringlike = response_body)
      hc = HasContent.new(content)
      assert hc.matches?(stringlike), hc.failure_message
    end

    # Asserts that the stringlike object (or body of the response)
    # does not contain the supplied string or regepx
    def assert_not_contain(content, stringlike = response_body)
      hc = HasContent.new(content)
      assert !hc.matches?(stringlike), hc.negative_failure_message
    end

  end
end
