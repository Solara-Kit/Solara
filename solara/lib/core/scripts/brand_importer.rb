require 'json'
require 'fileutils'

class BrandImporter

    def start(configurations_paths)

        configurations_paths.each do |path|
            import(path)
        end
    end

    private

    def import(configurations_path)
        unless File.exist?(configurations_path)
            Solara.logger.failure("#{configurations_path} doesn't exist!")
            return
        end
        
        unless File.file?(configurations_path)
            Solara.logger.failure("#{configurations_path} is not configurations file!")
            return
        end

        validate_json(configurations_path)
        validate_json_schema(configurations_path)

        configurations = JSON.parse(File.read(configurations_path))
        brand = configurations['brand']
        brand_key = brand['key'] # Ensure to use 'key' instead of 'brand_key'

        exists = BrandsManager.instance.exists(brand_key)
        unless exists
            SolaraManager.new.onboard(brand_key, brand['name'], open_dashboard: false)
        end

        SolaraManager.new.sync_brand_with_template(brand_key) if exists
        update_brand(brand_key, configurations)

        message_suffix = exists ? "The existing brand '#{brand_key}' has been updated." : "A new brand with the key '#{brand_key}' has been onboarded."
        Solara.logger.success("Successfully imported (#{configurations_path}). #{message_suffix}")
    end

    def update_brand(brand_key, configurations)
        configurations['configurations'].each do |configuration|
            filename = configuration['filename']
            data = configuration['content']
            BrandConfigUpdater.new.update(filename, data, brand_key)
        end
    end

    def validate_json(configurations_path)
        begin
            JsonFileValidator.new([configurations_path]).validate
        rescue StandardError => e
            Solara.logger.fatal(e.message)
            exit 1
        end
    end

    def validate_json_schema(configurations_path)
        begin
            schema_path = FilePath.brand_configurations_schema
            JsonSchemaValidator.new(schema_path, configurations_path).validate
        rescue StandardError => e
            Solara.logger.fatal(e.message)
            exit 1
        end
    end

end