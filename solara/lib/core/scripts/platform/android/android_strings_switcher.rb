class AndroidStringsSwitcher
    def initialize(brand_key)
        @brand_key = brand_key
      end

    def switch
        Solara.logger.log_step("Switch strings.xml") do
            switch_brand_name
            remove_original_app_name_from_strings
        end
    end

    private

    def switch_brand_name
        brand_config_path = FilePath.brand_config(@brand_key)
        brand_config = JSON.parse(File.read(brand_config_path))
        strings_path = FilePath.android_artifacts_strings
        manager = StringsXmlManager.new(strings_path)
        app_name_value = manager.get_value('app_name')

        # If user has specified a brandName in brand_config, we don't override it.
        if !app_name_value.nil? && !app_name_value.empty?
            Solara.logger.debug("App name is specified in #{strings_path}. Skipping updating from #{brand_config_path}!")
            return
        end

        manager.update_string_value('app_name', brand_config['brandName'])
        Solara.logger.debug("Updated app anme in #{strings_path} from #{brand_config_path}.")
    end

    # It's important to delete app_name to avoid duplicate resources
    def remove_original_app_name_from_strings
        file_path = FilePath.android_strings
        return unless File.exist?(file_path)
        
        manager = StringsXmlManager.new(file_path)
        manager.delete_app_name
    end

end