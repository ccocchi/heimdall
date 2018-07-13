module HeimdallApm
  class UriMatcher
    def initialize(prefixes)
      @prefixes = Array(prefixes)
    end

    def match?(uri)
      @prefixes.empty? ? false : uri.start_with?(*@prefixes)
    end
  end
end
