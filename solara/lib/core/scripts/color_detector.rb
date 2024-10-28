class ColorDetector
    def initialize(value)
      @value = value
    end

    def color?
      # Check for 6-character (RGB) or 8-character (RGBA) hex color formats
      @value.is_a?(String) && @value.match?(/^#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$/)
    end
  end