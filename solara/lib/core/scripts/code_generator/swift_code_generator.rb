class SwiftCodeGenerator
    def initialize(json, parent_class_name, registry = nil)
      @json = json
      @parent_class_name = parent_class_name
      @registry = registry || ClassNameRegistry.new
      @generated_classes = []
    end

    def generate
      imports = "import UIKit\n\n"
      generate_class(@json, @parent_class_name)
      imports + @generated_classes.reverse.join("\n\n")
    end

    private

    def generate_class(json_obj, class_name)
      @registry.register(class_name, class_name)
      class_name = @registry.get_class_name(class_name, class_name)
      return if @generated_classes.any? { |c| c.include?("struct #{class_name}") }

      properties = []
      static_values = []

      json_obj.each do |key, value|
        nested_class_name = "#{class_name}#{StringCase.capitalize(key)}"
        @registry.register(nested_class_name, nested_class_name)
        nested_class_name = @registry.get_class_name(nested_class_name, nested_class_name)

        type = determine_type(value, nested_class_name, "#{class_name}.#{key}")

        if value.is_a?(Hash)
          generate_class(value, nested_class_name)
          static_values << "private static let #{key}Value = #{nested_class_name}.shared"
        elsif value.is_a?(Array) && !value.empty? && value.first.is_a?(Hash)
          generate_class(value.first, nested_class_name)
          type = "[#{nested_class_name}]"
          list_values = value.map { |_| "#{nested_class_name}.shared" }
          static_values << "private static let #{key}Value = [#{list_values.join(", ")}]"
        else
          static_values << "private static let #{key}Value = #{swift_value(value)}"
        end

        properties << "let #{key}: #{type}"
      end

      class_code = <<~SWIFT
        struct #{class_name} {
            #{properties.join("\n    ")}

            private static var _shared: #{class_name}?

            #{static_values.join("\n    ")}

            static var shared: #{class_name} {
                if _shared == nil {
                    _shared = #{class_name}(
                        #{json_obj.keys.map { |key| "#{key}: #{key}Value" }.join(",\n                      ")}
                    )
                }
                return _shared!
            }
        }
      SWIFT

      @generated_classes << class_code
    end

    def determine_type(value, class_name, registry_key)
      base_type = if value.is_a?(String) && ColorDetector.new(value).color?
        "UIColor"
      elsif value.is_a?(String)
        "String"
      elsif value.is_a?(Integer)
        "Int"
      elsif value.is_a?(Float)
        "Double"
      elsif value.is_a?(TrueClass) || value.is_a?(FalseClass)
        "Bool"
      elsif value.is_a?(Array)
        item_type = value.empty? ? "Any" : determine_type(value.first, class_name, "#{registry_key}[]")
        "[#{item_type}]"
      elsif value.is_a?(Hash)
        class_name
      else
        "Any"
      end

      @registry.get_type(value, base_type)
    end

    def swift_value(value)
      if value.is_a?(String) && ColorDetector.new(value).color?
        hex = value.gsub('#', '')
        r = "Double(0x#{hex[0,2]}) / 255.0"
        g = "Double(0x#{hex[2,2]}) / 255.0"
        b = "Double(0x#{hex[4,2]}) / 255.0"
        a = hex.length == 8 ? "Double(0x#{hex[6,2]}) / 255.0" : "1.0"
        return "UIColor(red: #{r}, green: #{g}, blue: #{b}, alpha: #{a})"
      end
      return "\"#{value}\"" if value.is_a?(String)
      return value.to_s if value.is_a?(Integer) || value.is_a?(Float)
      return value.to_s.downcase if value.is_a?(TrueClass) || value.is_a?(FalseClass)
      return "[#{value.map { |v| swift_value(v) }.join(", ")}]" if value.is_a?(Array)
      return "nil" if value.nil?
      value.to_s
    end
end