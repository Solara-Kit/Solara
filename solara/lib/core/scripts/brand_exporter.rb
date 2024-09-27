require 'json'
require 'fileutils'

class BrandExporter

    def start(brand_keys, path)
        if !path.nil? && !path.strip.empty? && !File.directory?(path)
            Solara.logger.failure("#{path} is not a directory. Please specify a valid directory.")
            return
        end

        directory = path || FilePath.project_root

        brand_keys.each do |brand_key|
            export(brand_key, directory)
        end
    end

    private

    def export(brand_key, directory)
        unless BrandsManager.instance.exists(brand_key)
            Solara.logger.failure("#{brand_key} doesn't exist!")
            return
        end
        
        brand = BrandsManager.instance.brand_with_configurations(brand_key)
        json = JSON.pretty_generate(brand)
        json_file_path = File.join(directory, "#{brand_key}-solara-configurations.json")

        # Create the file if it does not exist
        File.open(json_file_path, 'w') do |file|
            file.write(json)
        end

        Solara.logger.success("Successfully exported brand #{brand_key} to: #{json_file_path}")
    end
end