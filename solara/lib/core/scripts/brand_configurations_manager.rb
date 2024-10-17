class BrandConfigurationsManager

    def initialize(brand_key)
        @brand_key = brand_key
    end

    def template_with_key(key)
        templates.select { |section| section[:key] === key }.first
    end

    def templates
        configurations = JSON.parse(File.read(FilePath.brand_configurations))['configurations']
        configurations.map do |config|
            {
                key: config['key'],
                name: config['name'],
                path: "#{FilePath.brand(@brand_key)}/#{config['filePath']}"
            }
        end
    end

    def create
        config_templates = templates

        config_templates.map do |template|
            create_config_item(
                template[:key],
                template[:name],
                template[:path]
            )
        end
    end

    def create_config_item(key, name, path)
        {
            key: key,
            name: name,
            content: JSON.parse(File.read(path)),
        }
    end
end