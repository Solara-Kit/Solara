class DartCodeGenerator
  def initialize(json, parent_class_name, registry = nil)
    @json = json
    @parent_class_name = parent_class_name
    @registry = registry || ClassNameRegistry.new
    @generated_classes = []
  end

  def generate
    imports = "import 'package:flutter/material.dart';\n\n"
    generate_class(@json, @parent_class_name)
    imports + @generated_classes.reverse.join("\n\n")
  end

  private

  def generate_class(json_obj, class_name)
    @registry.register(class_name, class_name)
    class_name = @registry.get_class_name(class_name, class_name)
    return if @generated_classes.any? { |c| c.include?("class #{class_name}") }

    properties = []
    constructor_params = []
    companion_values = []
    instance_values = []

    json_obj.each do |key, value|
      nested_class_name = "#{class_name}#{StringCase.capitalize(key)}"
      @registry.register(nested_class_name, nested_class_name)
      nested_class_name = @registry.get_class_name(nested_class_name, nested_class_name)

      type = determine_type(value, nested_class_name, "#{class_name}.#{key}")

      if value.is_a?(Hash)
        generate_class(value, nested_class_name)
        companion_values << "static final #{key}Value = #{nested_class_name}.instance;"
      elsif value.is_a?(Array) && !value.empty? && value.first.is_a?(Hash)
        generate_class(value.first, nested_class_name)
        type = "List<#{nested_class_name}>"
        list_values = value.map { |_| "#{nested_class_name}.instance" }
        companion_values << "static final #{key}Value = <#{nested_class_name}>[#{list_values.join(", ")}];"
      else
        companion_values << "static final #{key}Value = #{dart_value(value)};"
      end

      properties << "final #{type} #{key};"
      constructor_params << "required this.#{key}"
      instance_values << "#{key}: #{key}Value"
    end

    class_code = <<~DART
      class #{class_name} {
        #{properties.join("\n  ")}

        const #{class_name}({#{constructor_params.join(", ")}});

        static #{class_name}? _instance;

        #{companion_values.join("\n    ")}

        static #{class_name} get instance {
          _instance ??= #{class_name}(
            #{instance_values.join(",\n            ")}
          );
          return _instance!;
        }
      }
    DART

    @generated_classes << class_code
  end

  def determine_type(value, class_name, registry_key)
    base_type = if value.is_a?(String) && ColorDetector.new(value).color?
      "Color"
    elsif value.is_a?(String)
      "String"
    elsif value.is_a?(Integer)
      "int"
    elsif value.is_a?(Float)
      "double"
    elsif value.is_a?(TrueClass) || value.is_a?(FalseClass)
      "bool"
    elsif value.is_a?(Array)
      item_type = value.empty? ? "dynamic" : determine_type(value.first, class_name, "#{registry_key}[]")
      "List<#{item_type}>"
    elsif value.is_a?(Hash)
      class_name
    else
      "dynamic"
    end

    @registry.get_type(value, base_type)
  end

  def dart_value(value)
    if value.is_a?(String) && ColorDetector.new(value).color?
      hex = value.gsub('#', '')
      if hex.length == 8
        return "Color(0x#{hex})"
      else
        return "Color(0xFF#{hex})"
      end
    end
    return "\"#{value}\"" if value.is_a?(String)
    return value.to_s if value.is_a?(Integer) || value.is_a?(Float)
    return value.to_s.downcase if value.is_a?(TrueClass) || value.is_a?(FalseClass)
    return "<#{determine_type(value.first, '', '')}>[#{value.map { |v| dart_value(v) }.join(", ")}]" if value.is_a?(Array)
    return "null" if value.nil?
    value.to_s
  end
end