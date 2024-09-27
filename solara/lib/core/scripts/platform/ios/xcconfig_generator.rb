class XcconfigGenerator
    def initialize(brand_key)
        @brand_key = brand_key
        @platform = SolaraSettingsManager.instance.platform
    end

    def generate
        Solara.logger.start_step("Generate Brand.xcconfig for iOS")
        destination = FilePath.brand_xcconfig
        content = generate_xcconfig_content
        File.write(destination, content)
        Solara.logger.debug("🎉 Generated #{FilePath.brand_xcconfig}. Content below ⬇️")
        Solara.logger.debug("--------------\n#{content}--------------")
        Solara.logger.end_step("Generate Brand.xcconfig for iOS")
    end

    private

    def generate_xcconfig_content
        content = <<~XCCONFIG
          APPICON_NAME = AppIcon
          PRODUCT_NAME = #{get_value_of(InfoPListKey::BUNDLE_DISPLAY_NAME)}
          CFBUNDLE_DISPLAY_NAME = #{get_value_of(InfoPListKey::BUNDLE_DISPLAY_NAME)}
          CFBUNDLE_NAME = #{get_value_of(InfoPListKey::BUNDLE_NAME)}
          #{load_config.map { |key, value| "#{key.upcase} = #{value}" }.join("\n")}
        XCCONFIG

        case @platform
        when Platform::Flutter
            # "../Generated.xcconfig" is the config related to Flutter itself, we must include it here.
            <<~XCCONFIG
              #include "../Generated.xcconfig"

              #{content}
            XCCONFIG
        when Platform::IOS
            content
        else
            raise ArgumentError, "Invalid platform: #{@platform}"
        end
    end

    def get_value_of(key)
        infoplist_value = InfoPListStringCatalogManager.new(FilePath.brand_infoplist_string_catalog(@brand_key)).get(key)
        return infoplist_value if !infoplist_value && !infoplist_value.empty?

        brand_config_path = FilePath.brand_config(@brand_key)
        brand_config = JSON.parse(File.read(brand_config_path))
        brand_config['brandName']
    end

    def load_config
        config_path = FilePath.ios_config(@brand_key)
        JSON.parse(File.read(config_path))
    end
end