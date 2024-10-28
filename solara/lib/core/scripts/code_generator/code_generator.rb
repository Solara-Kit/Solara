module Language
  Kotlin = 'kotlin'
  Swift = 'swift'
  Dart = 'dart'

  def self.all
    [Kotlin, Swift, Dart]
  end

  def self.init(language)
    if all.include?(language)
      # Do something with the valid language
    else
      raise ArgumentError, "Invalid language. Please use one of: #{all.join(', ')}"
    end
  end
end

class CodeGenerator
  def initialize(
    json:,
    language:,
    parent_class_name:,
    custom_types: {}
  )
    @json = json
    @language = language
    @parent_class_name = parent_class_name
    @custom_types = custom_types
    @generator = create_language_generator
  end

  def generate
    @generator.generate unless @generator.nil?
  end

  private

  def create_language_generator
    registry = ClassNameRegistry.new(@custom_types)

    case @language
    when Language::Kotlin
      KotlinCodeGenerator.new(@json, @parent_class_name, registry)
    when Language::Swift
      SwiftCodeGenerator.new(@json, @parent_class_name, registry)
    when Language::Dart
      DartCodeGenerator.new(@json, @parent_class_name, registry)
    else
      raise ArgumentError, "Unsupported language: #{@language}"
    end
  end
end
