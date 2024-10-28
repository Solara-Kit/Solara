class ClassNameRegistry
  def initialize(custom_types = {})
    @registry = {}
    @custom_types = custom_types
  end

  def register(key, class_name)
    @registry[key] = class_name
  end

  def get_class_name(key, default_name)
    @custom_types[key] || @registry[key] || default_name
  end

  def get_type(value, default_type)
    type_key = generate_type_key(value, default_type)
    @custom_types[type_key] || default_type
  end

  private

  def generate_type_key(value, default_type)
    case value
    when String then "String"
    when Integer then "int"
    when Float then "double"
    when TrueClass, FalseClass then "bool"
    when Array then "List"
    when Hash then default_type # class name
    else default_type
    end
  end
end