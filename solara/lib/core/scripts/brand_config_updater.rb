class BrandConfigUpdater

    def update(filename, data, brand_key)
        template = BrandConfigurationsManager.new(brand_key).template_with_filename(filename)

        path = template[:path]
        json = JSON.pretty_generate(data)

        begin
            # Check if the file exists
            if File.exist?(path)
                # If it exists, update the file
                File.write(path, json)
                Solara.logger.debug("Updated Config for #{path}: #{data}")
            else
                # If it doesn't exist, create the file with the data
                File.write(path, json)
                Solara.logger.debug("Created Config for #{path}: #{data}")
            end
        rescue StandardError => e
            Solara.logger.failure("Error updating #{brand_key} config file #{path}: #{e.message}")
            raise
        end
    end
end