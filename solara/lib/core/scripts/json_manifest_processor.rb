require 'json'

class JsonManifestProcessor

  def initialize(json_path, language, output_path)
    @json_path = json_path
    @language = language
    @output_path = output_path
  end

  def process
    manifest = read_json
    process_files(manifest)
  end

  private

  def process_files(manifest)
    manifest['files'].each do |file|
      generate_code(file)
    end
  end

  def generate_code(file)
      return unless file['generate']['enabled']

      file_name = file['fileName']
      class_name = file['generate']['className']

      puts "generate_code: file_name = #{file_name}, class_name = #{class_name}"
      return if file_name.empty? || class_name.empty?
      puts "generate_code: file_name = #{file_name}, class_name = #{class_name}"

      custom_class_names = convert_to_map(file['generate']['customClassNames'])

      file_path = File.join(@json_path, file_name)
      code_generator = CodeGenerator.new(
        json: JSON.parse(File.read(file_path)),
        language: @language ,
        parent_class_name: class_name,
        custom_types: custom_class_names
      )

      generated_code = code_generator.generate

      output_path = File.join(@output_path, gnerated_filename(class_name))
      write_to_file(output_path, generated_code)
  end

  def gnerated_filename(class_name)
    case SolaraSettingsManager.instance.platform
    when Platform::Flutter
      "#{to_snake_case(class_name)}.dart"
    when Platform::IOS
      "#{class_name}.swift"
    when Platform::Android
      "#{class_name}.kt"
    else
      raise ArgumentError, "Invalid platform: #{@platform}"
    end
  end

  def to_snake_case(string)
    string.gsub(/[A-Z]/) { |match| "_#{match.downcase}" }.sub(/^_/, '')
  end

  def write_to_file(output, content)
    puts "generate_code: output = #{output}, content = #{content}"
    File.write(output, content)
    Solara.logger.debug("Genrated #{output}")
  rescue StandardError => e
    Solara.logger.debug("Error writing to file #{file_name}: #{e.message}")
  end

  def convert_to_map(custom_class_names)
    custom_class_names.each_with_object({}) do |item, result|
      result[item['generatedName']] = item['customName']
    end
  end

  def read_json
    mainfest_path = File.join(@json_path, 'json_manifest.json')
    JSON.parse(File.read(mainfest_path))
  rescue JSON::ParserError => e
    Solara.logger.debug("Error parsing JSON: #{e.message}")
    {}
  rescue Errno::ENOENT => e
    Solara.logger.debug("Error reading file: #{e.message}")
    {}
  rescue StandardError => e
    Solara.logger.debug("Unexpected error: #{e.message}")
    {}
  end

end