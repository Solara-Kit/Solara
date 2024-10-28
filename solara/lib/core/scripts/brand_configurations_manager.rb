class BrandConfigurationsManager

    def initialize(brand_key)
        @brand_key = brand_key
    end

    def template_with_filename(filename)
        templates.select { |template| template[:filename] === filename }.first
    end

    def templates
        TemplateManager.new(@brand_key).templates
    end

    def create
        config_templates = templates

        config_templates.map do |template|
            create_config_item(
                template[:filename],
                template[:name],
                template[:path]
            )
        end
    end

    def create_config_item(filename, name, path)
        {
            filename: filename,
            name: name,
            content: JSON.parse(File.read(path)),
        }
    end
end

class TemplateManager

    def initialize(brand_key)
        @brand_key = brand_key
    end

    def templates
      result = parse_configurations
      collect_json_templates.each do |template|
        result << template unless result.any? { |r| r['filename'] == template['filename'] }
      end
      result.compact
    rescue StandardError => e
      Solara.logger.error("Failed to generate templates: #{e.message}")
      []
    end

    private

    def parse_configurations
      configurations = JSON.parse(File.read(FilePath.brand_configurations))['configurations']
      configurations.map do |config|
        path = build_path(config['filePath'])
        next unless File.exist?(path)

        filename_without_extension = File.basename(config['filename'], '.json')

        {
          filename: File.basename(config['filename']),
          name: StringCase.snake_to_capitalized_spaced(filename_without_extension, exclude: "ios"),
          path: path
        }
      end
    rescue StandardError => e
      Solara.logger.error("Failed to parse configurations: #{e.message}")
      []
    end

    def collect_json_templates
      directories = [
        FilePath.brand_global_json_dir,
        FilePath.brand_json_dir(@brand_key)
      ]

      directories.flat_map do |dir|
        get_json_files(dir).map do |file|
          filename_without_extension = File.basename(file, '.json')

          {
            filename: File.basename(file),
            name: StringCase.snake_to_capitalized_spaced(filename_without_extension, exclude: "ios"),
            path: file
          }
        end
      end
    end

    def get_json_files(dir)
      Dir.glob(File.join(dir, '**', '*.json'))
    rescue StandardError => e
      Solara.logger.error("Error reading directory #{dir}: #{e.message}")
      []
    end

    def build_path(file_path)
      "#{FilePath.brand(@brand_key)}/#{file_path}"
    end
  end