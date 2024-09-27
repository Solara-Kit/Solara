class BrandConfigurationsManager

    def initialize(brand_key)
        @brand_key = brand_key
    end

    def template_with_key(key)
        templates.select { |section| section[:key] === key }.first
    end

    def templates
        [
            {
                key: 'brand_config.json',
                name: 'Brand Configuration',
                input_type: 'text',
                path: FilePath.brand_config(@brand_key)
            },
            {
                key: 'theme.json',
                name: 'Theme Configuration',
                input_type: 'color',
                path: FilePath.brand_theme(@brand_key)
            },
            {
                key: 'android_config.json',
                name: 'Android Configuration',
                input_type: 'text',
                path: FilePath.android_brand_config(@brand_key)
            },
            {
                key: 'android_signing.json',
                name: 'Android Signing',
                input_type: 'text',
                path: FilePath.brand_signing(@brand_key, Platform::Android)
            },
            {
                key: 'ios_config.json',
                name: 'iOS Configuration',
                input_type: 'text',
                path: FilePath.ios_config(@brand_key)
            },
            {
                key: 'ios_signing.json',
                name: 'iOS Signing',
                input_type: 'text',
                path: FilePath.brand_signing(@brand_key, Platform::IOS)
            }
        ]
    end

    def create
        config_templates = templates

        config_templates.map do |template|
            create_config_item(
                template[:key],
                template[:name],
                template[:input_type],
                template[:path].tap { |p| File.expand_path(p) }
            )
        end
    end

    def create_config_item(key, name, input_type, path)
        {
            key: key,
            name: name,
            inputType: input_type,
            content: JSON.parse(File.read(path)),
        }
    end
end