require 'json'

class JsonManifestProcessor
  def initialize(json_path, language, output_path)
    @json_path = json_path
    @language = language
    @output_path = output_path
    @manifest = read_manifest
  end

  def process
    # First process files specified in manifest
    process_manifest_files if @manifest && @manifest['files']

    # Then process remaining JSON files
    process_remaining_files
  end

  private

  def read_manifest
    manifest_path = File.join(@json_path, 'json_manifest.json')
    JSON.parse(File.read(manifest_path))
  rescue JSON::ParserError => e
    Solara.logger.debug("Error parsing manifest JSON: #{e.message}")
    nil
  rescue Errno::ENOENT => e
    Solara.logger.debug("Manifest file not found: #{e.message}")
    nil
  rescue StandardError => e
    Solara.logger.debug("Unexpected error reading manifest: #{e.message}")
    nil
  end

  def process_manifest_files
    @manifest['files'].each do |file|
      process_manifest_file(file)
    end
  end

  def process_manifest_file(file)
    return unless file['generate']

    file_name = file['fileName']
    class_name = file['parentClassName']

    return if file_name.empty? || class_name.empty?

    custom_class_names = convert_to_map(file['customClassNames'])
    process_json_file(
      File.join(@json_path, file_name),
      class_name,
      custom_class_names,
      true
    )
  end

  def process_remaining_files
    manifest_files = @manifest&.dig('files')&.map { |f| f['fileName'] } || []

    json_files = get_json_files
    json_files.each do |file_path|
      file_name = File.basename(file_path)
      # Skip files that were already processed via manifest
      next if manifest_files.include?(file_name)
      next if file_name == 'json_manifest.json'

      class_name = derive_class_name(file_name)
      process_json_file(file_path, class_name, {}, false)
    end
  end

  def get_json_files
    Dir.glob(File.join(@json_path, '**', '*.json'))
  rescue StandardError => e
    Solara.logger.debug("Error reading directory #{@json_path}: #{e.message}")
    []
  end

  def process_json_file(file_path, class_name, custom_types, is_manifest_file)
    begin
      json_content = JSON.parse(File.read(file_path))
      code_generator = CodeGenerator.new(
        json: json_content,
        language: @language,
        parent_class_name: class_name,
        custom_types: custom_types
      )

      generated_code = code_generator.generate
      output_path = File.join(@output_path, generated_filename(class_name))
      write_to_file(output_path, generated_code)
    rescue JSON::ParserError => e
      Solara.logger.debug("Error parsing JSON file #{File.basename(file_path)}: #{e.message}")
    rescue StandardError => e
      Solara.logger.debug("Error processing file #{File.basename(file_path)}: #{e.message}")
    end
  end

  def derive_class_name(file_name)
    # Remove .json extension and convert to PascalCase
    base_name = File.basename(file_name, '.json')
    base_name.split('_').map(&:capitalize).join
  end

  def convert_to_map(custom_class_names)
    return {} unless custom_class_names
    custom_class_names.each_with_object({}) do |item, result|
      result[item['originalName']] = item['customName']
    end
  end

  def generated_filename(class_name)
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
    File.write(output, content)
    Solara.logger.debug("Generated #{output}")
  rescue StandardError => e
    Solara.logger.debug("Error writing to file #{output}: #{e.message}")
  end
end