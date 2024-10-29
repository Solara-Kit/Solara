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

    def generate_class(json_obj, class_name, list_items = nil)
      @registry.register(class_name, class_name)
      class_name = @registry.get_class_name(class_name, class_name)
      return if @generated_classes.any? { |c| c.include?("struct #{class_name}") }

      properties = []
      static_values = []
      instance_values = []

      json_obj.each do |key, value|
        nested_class_name = "#{class_name}#{StringCase.capitalize(key)}"
        @registry.register(nested_class_name, nested_class_name)
        nested_class_name = @registry.get_class_name(nested_class_name, nested_class_name)

        type = determine_type(value, nested_class_name, "#{class_name}.#{key}")

        if value.is_a?(Hash)
          generate_class(value, nested_class_name)
          static_values << "private static let #{key}Value = #{nested_class_name}.shared"
          instance_values << "#{key}: #{nested_class_name}.shared"
        elsif value.is_a?(Array) && !value.empty? && value.first.is_a?(Hash)
          generate_class(value.first, nested_class_name, value)
          type = "[#{nested_class_name}]"
          static_values << "private static let #{key}Value = #{nested_class_name}.instances"
          instance_values << "#{key}: #{nested_class_name}.instances"
        else
          static_values << "private static let #{key}Value = #{swift_value(value)}"
          instance_values << "#{key}: #{key}Value"
        end

        properties << "let #{key}: #{type}"
      end

      static_instances = if list_items
        items_code = list_items.map.with_index do |item, index|
          values = item.map do |key, value|
            if value.is_a?(Hash)
              nested_class_name = "#{class_name}#{StringCase.capitalize(key)}"
              @registry.register(nested_class_name, nested_class_name)
              nested_class_name = @registry.get_class_name(nested_class_name, nested_class_name)
              "#{key}: #{nested_class_name}.shared"
            elsif value.is_a?(Array) && !value.empty? && value.first.is_a?(Hash)
              nested_class_name = "#{class_name}#{StringCase.capitalize(key)}"
              @registry.register(nested_class_name, nested_class_name)
              nested_class_name = @registry.get_class_name(nested_class_name, nested_class_name)
              "#{key}: #{nested_class_name}.instances"
            else
              "#{key}: #{swift_value(value)}"
            end
          end.join(",\n                ")
          "    private static let instance#{index + 1} = #{class_name}(\n                #{values}\n            )"
        end.join("\n")

        instances_list = (1..list_items.length).map { |i| "instance#{i}" }.join(", ")

        <<~SWIFT
          #{items_code}

          static let instances: [#{class_name}] = [#{instances_list}]
        SWIFT
      else
        <<~SWIFT
          private static var _shared: #{class_name}?

          #{static_values.join("\n    ")}

          static var shared: #{class_name} {
              if _shared == nil {
                  _shared = #{class_name}(
                      #{instance_values.join(",\n                    ")}
                  )
              }
              return _shared!
          }
        SWIFT
      end

      class_code = <<~SWIFT
        struct #{class_name} {
            #{properties.join("\n      ")}

            #{static_instances}
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