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

        configurations_json = JSON.parse(File.read(configurations_path))
        brand = configurations_json['brand']
        brand_key = brand['key'] # Ensure to use 'key' instead of 'brand_key'

        exists = BrandsManager.instance.exists(brand_key)
        unless exists
            SolaraManager.new.onboard(brand_key, brand['name'], open_dashboard: false)
        end

        update_brand(brand_key, configurations_json)

        message_suffix = exists ? "The existing brand '#{brand_key}' has been updated." : "A new brand with the key '#{brand_key}' has been onboarded."
        Solara.logger.success("Successfully imported (#{configurations_path}). #{message_suffix}")
    end

    def update_brand(brand_key, configurations_json)
        brand_path = FilePath.brand(brand_key)

        configurations_json['configurations'].each do |configuration|
            file_name = configuration['key']
            file_path = find_file_in_subdirectories(brand_path, file_name)

            # Create or replace the contents of the configuration file
            if file_path
                File.write(file_path, JSON.pretty_generate(configuration['content']))
            else
                Solara.logger.failure("File #{file_name} not found in #{brand_path}, ignoring importing it!")
            end
        end
    end

    def find_file_in_subdirectories(base_path, file_name)
        Dir.glob(File.join(base_path, '**', file_name)).first
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