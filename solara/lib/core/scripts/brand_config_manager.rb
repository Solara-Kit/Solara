Dir.glob("#{__dir__}/../scripts/platform/android/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/../scripts/platform/ios/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/../scripts/code_generator/*.rb").each { |file| require file }

class BrandConfigManager
    def initialize(brand_key)
        @brand_key = brand_key
    end

    def generate_brand_config(
        name,
        language,
        platform)
        Solara.logger.start_step("Generate #{name} for #{platform}")
        config = load_config(FilePath.brand_config(@brand_key))
        add_basic_brand_info(config, platform)
        config_generator = CodeGenerator.new(
            json: config,
            language: language,
            parent_class_name: 'BrandConfig',
        )
        output_dir = FilePath.generated_config(name, platform)
        content = config_generator.generate
        FileManager.create_file_if_not_exist(output_dir)
        File.write(output_dir, content)
        Solara.logger.debug("Generated brand config #{output_dir} for: #{@language}")

        Solara.logger.end_step("Generate #{name} for #{platform}")
    end

    def generate_android_properties
        generator = PropertiesGenerator.new(@brand_key)
        generator.generate
    end

    def generate_ios_xcconfig
        generator = XcconfigGenerator.new(@brand_key)
        generator.generate
    end

    private

    def add_basic_brand_info(config, platform)
        case platform
        when Platform::Flutter
            add_android_info(config, prefix: 'android')
            add_ios_info(config, prefix: 'iOS')
        when Platform::Android
            add_android_info(config)
        when Platform::IOS
            add_ios_info(config)
        else
            raise ArgumentError, "Invalid platform: #{@platform}"
        end
    end

    def add_android_info(config, prefix: '')
        android_config = load_config(FilePath.android_config(@brand_key))
        config_mappings = {
            'applicationId' => 'ApplicationId',
            'versionName' => 'VersionName',
            'versionCode' => 'VersionCode'
        }

        add_config_info(config, android_config, config_mappings, prefix)
    end

    def add_ios_info(config, prefix: '')
        ios_config = load_config(FilePath.ios_config(@brand_key))
        config_mappings = {
            'PRODUCT_BUNDLE_IDENTIFIER' => 'BundleIdentifier',
            'MARKETING_VERSION' => 'MarketingVersion',
            'BUNDLE_VERSION' => 'BundleVersion'
        }

        add_config_info(config, ios_config, config_mappings, prefix)
    end

    def add_config_info(config, source_config, mappings, prefix)
        mappings.each do |source_key, target_key|
            key = if prefix.empty?
                      target_key[0].downcase + target_key[1..]
                  else
                      "#{prefix}#{target_key}"
                  end
            config[key] = source_config[source_key]
        end
    end

    def load_config(file_path)
        JSON.parse(File.read(file_path))
    end
end