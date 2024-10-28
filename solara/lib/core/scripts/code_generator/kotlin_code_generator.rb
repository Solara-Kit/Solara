class KotlinCodeGenerator
  def initialize(json, parent_class_name, registry = nil)
    @json = json
    @parent_class_name = parent_class_name
    @registry = registry || ClassNameRegistry.new
    @generated_classes = []
  end

  def generate
    imports = "import android.graphics.Color\n\n"
    generate_class(@json, @parent_class_name)
    imports + @generated_classes.reverse.join("\n\n")
  end

  private

  def generate_class(json_obj, class_name)
    @registry.register(class_name, class_name)
    class_name = @registry.get_class_name(class_name, class_name)
    return if @generated_classes.any? { |c| c.include?("data class #{class_name}") }

    properties = []
    companion_values = []

    json_obj.each do |key, value|
      nested_class_name = "#{class_name}#{StringCase.capitalize(key)}"
      @registry.register(nested_class_name, nested_class_name)
      nested_class_name = @registry.get_class_name(nested_class_name, nested_class_name)

      type = determine_type(value, nested_class_name, "#{class_name}.#{key}")

      if value.is_a?(Hash)
        generate_class(value, nested_class_name)
        companion_values << "private val #{key}Value = #{nested_class_name}.instance"
      elsif value.is_a?(Array) && !value.empty? && value.first.is_a?(Hash)
        generate_class(value.first, nested_class_name)
        type = "List<#{nested_class_name}>"
        list_values = value.map { |_| "#{nested_class_name}.instance" }
        companion_values << "private val #{key}Value = listOf(#{list_values.join(", ")})"
      else
        companion_values << "private val #{key}Value = #{kotlin_value(value)}"
      end

      properties << "val #{key}: #{type}"
    end

    class_code = <<~KOTLIN
      data class #{class_name}(
          #{properties.join(",\n          ")}
      ) {
          companion object {
              private var _instance: #{class_name}? = null

              #{companion_values.join("\n          ")}

              val instance: #{class_name}
                  get() {
                      if (_instance == null) {
                          _instance = #{class_name}(
                              #{json_obj.keys.map { |key| "#{key} = #{key}Value" }.join(",\n                              ")}
                          )
                      }
                      return _instance!!
                  }
          }
      }
    KOTLIN

    @generated_classes << class_code
  end

  def determine_type(value, class_name, registry_key)
    base_type = if value.is_a?(String) && ColorDetector.new(value).color?
      "Int"
    elsif value.is_a?(String)
      "String"
    elsif value.is_a?(Integer)
      "Int"
    elsif value.is_a?(Float)
      "Double"
    elsif value.is_a?(TrueClass) || value.is_a?(FalseClass)
      "Boolean"
    elsif value.is_a?(Array)
      item_type = value.empty? ? "Any" : determine_type(value.first, class_name, "#{registry_key}[]")
      "List<#{item_type}>"
    elsif value.is_a?(Hash)
      class_name
    else
      "Any"
    end

    @registry.get_type(value, base_type)
  end

  def kotlin_value(value)
    if value.is_a?(String) && ColorDetector.new(value).color?
      hex = value.gsub('#', '')
      if hex.length == 8
        return "Color.parseColor(\"##{hex}\")"
      else
        return "Color.parseColor(\"##{hex}\")"
      end
    end
    return "\"#{value}\"" if value.is_a?(String)
    return value.to_s if value.is_a?(Integer) || value.is_a?(Float)
    return value.to_s.downcase if value.is_a?(TrueClass) || value.is_a?(FalseClass)
    return "listOf(#{value.map { |v| kotlin_value(v) }.join(", ")})" if value.is_a?(Array)
    return "null" if value.nil?
    value.to_s
  end
end