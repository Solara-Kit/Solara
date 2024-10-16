Dir.glob("#{__dir__}/*.rb").each { |file| require file }

module FilePath

    def self.project_root
        SolaraSettingsManager.instance.project_root
    end

    def self.artifacts_dir_name
        'solara_artifacts'
    end

    def self.artifacts_dir_name_ios
        'SolaraArtifacts'
    end

    def self.root
        SolaraSettingsManager.instance.root
    end

    def self.android
        "android"
    end

    def self.test_lab
        File.join(ENV['HOME'], '.solara', 'testlab', 'src')
    end

    def self.test_lab_cache
        File.join(ENV['HOME'], '.solara', 'testlab', 'cache')
    end

    def self.android_project_root
        case SolaraSettingsManager.instance.platform
        when Platform::Flutter
            File.join(project_root, android)
        when Platform::Android
            project_root
        else
            raise ArgumentError, "Invalid platform: #{SolaraSettingsManager.instance.platform}"
        end
    end

    def self.ios_project_root
        case SolaraSettingsManager.instance.platform
        when Platform::Flutter
            File.join(project_root, ios)
        when Platform::IOS
            project_root
        else
            raise ArgumentError, "Invalid platform: #{SolaraSettingsManager.instance.platform}"
        end
    end

    def self.android_project_relative_root
        case SolaraSettingsManager.instance.platform
        when Platform::Flutter
            android
        when Platform::Android
            ''
        else
            raise ArgumentError, "Invalid platform: #{SolaraSettingsManager.instance.platform}"
        end
    end

    def self.android_brand_relative_root
        android
    end

    def self.android_brand_root(brand_key)
        brand_root(android, brand_key)
    end

    def self.ios_brand_root(brand_key)
        brand_root(ios, brand_key)
    end

    def self.brand_root(platform, brand_key)
        File.join(brands, brand_key, platform)
    end

    def self.dot_solara
        File.join(project_root, '.solara')
    end

    def self.ios
        "ios"
    end

    def self.solara_brand
        File.join(project_root, 'solara', 'brand')
    end

    def self.brands
        File.join(project_root, 'solara', 'brand', 'brands')
    end

    def self.brand(brand_key)
        File.join(brands, brand_key)
    end

    def self.android_config(brand_key)
        File.join(android_brand_root(brand_key), 'android_config.json')
    end

    def self.ios_config(brand_key)
        File.join(ios_brand_root(brand_key), 'ios_config.json')
    end

    def self.project_infoplist_string_catalog
        File.join(project_info_plist_directory, 'InfoPlist.xcstrings')
    end

    def self.brand_infoplist_string_catalog(brand_key)
        File.join(ios_brand_root(brand_key), 'InfoPlist.xcstrings')
    end

    def self.brand_fonts
        File.join(global, 'fonts')
    end

    def self.brand_resources_manifest
        File.join(global, 'brand_resources_manifest.json')
    end

    def self.global
        File.join(solara_brand, 'global')
    end

    def self.brand_config(brand_key)
        File.join(brands, brand_key, 'shared', 'brand_config.json')
    end

    def self.brand_theme(brand_key)
        File.join(brands, brand_key, 'shared', 'theme.json')
    end

    def self.brand_signing(brand_key, platform)
        config("#{platform}_signing.json", brand_key, platform)
    end

    def self.android_brand_signing(brand_key)
        brand_signing(brand_key, Platform::Android)
    end

    def self.ios_brand_signing(brand_key)
        brand_signing(brand_key, Platform::IOS)
    end

    def self.config(name, brand_key, platform = SolaraSettingsManager.instance.platform)
        case platform
        when Platform::Flutter
            File.join(brands, brand_key, 'shared', "#{name}")
        when Platform::Android
            File.join(android_brand_root(brand_key), "#{name}")
        when Platform::IOS
            File.join(ios_brand_root(brand_key), "#{name}")
        else
            raise ArgumentError, "Invalid platform: #{SolaraSettingsManager.instance.platform}"
        end
    end

    def self.generated_config(name, platform)
        case platform
        when Platform::Flutter
            File.join(flutter_lib_artifacts, name)
        when Platform::Android
            File.join(android_project_java_artifacts, name)
        when Platform::IOS
            File.join(ios_project_root_artifacts, name)
        else
            raise ArgumentError, "Invalid platform: #{SolaraSettingsManager.instance.platform}"
        end
    end

    def self.flutter_lib_artifacts
        File.join(project_root, 'lib', artifacts_dir_name)
    end

    def self.android_project_root_artifacts
        File.join(android_project_root, artifacts_dir_name)
    end

    def self.android_project_java_artifacts
        File.join(android_project_root, 'app', 'src', 'main', 'java', artifacts_dir_name)
    end

    def self.android_brand_config(brand_key)
        File.join(android_brand_root(brand_key), 'android_config.json')
    end

    def self.android_app_gradle
        File.join(android_project_root, 'app', gradle_name)
    end

    def self.android_app_gradle_by_type(type = '')
        File.join(android_project_root, 'app', "build.gradle#{type}")
    end

    def self.is_koltin_gradle
        File.exist?(android_app_gradle_by_type('.kts'))
    end

    def self.gradle_name
        is_koltin_gradle ? 'build.gradle.kts' : 'build.gradle'
    end

    def self.android_manifest
        File.join(android_project_root, 'app', 'src', 'main', 'AndroidManifest.xml')
    end

    def self.android_project_assets
        File.join(android_project_root, 'app', 'src', 'main', 'assets')
    end

    def self.android_project_assets_artifacts
        File.join(android_project_assets, artifacts_dir_name)
    end

    def self.android_brand_assets(brand_key)
        File.join(android_brand_root(brand_key), 'assets')
    end

    def self.android_generated_properties
        File.join(android_project_root_artifacts, 'brand.properties')
    end

    def self.android_project_res
        File.join(android_project_root, 'app', 'src', 'main', 'res')
    end

    def self.android_project_main_artifacts
        File.join(android_project_root, 'app', 'src', 'main', artifacts_dir_name)
    end

    def self.android_artifacts_strings
        File.join(android_project_main_artifacts, 'values', 'strings.xml')
    end

    def self.android_strings
        File.join(android_project_res, 'values', 'strings.xml')
    end

    def self.android_brand_res(brand_key)
        File.join(android_brand_root(brand_key), 'res')
    end

    def self.brand_flutter_assets(brand_key)
        File.join(brands, brand_key, 'flutter', 'assets')
    end

    def self.flutter_assets_artifacts
        File.join(project_root, 'assets', artifacts_dir_name)
    end

    def self.pub_spec_yaml
        File.join(project_root, 'pubspec.yaml')
    end

    def self.flutter_lib_artifacts_config
        File.join(flutter_lib_artifacts, 'app_config.dart')
    end

    def self.dashboard
        File.join(root, 'core', 'dashboard')
    end

    def self.brands_list
        File.join(brands, 'brands.json')
    end

    def self.current_brand
        File.join(brands, 'current_brand.json')
    end

    def self.template_brands
        File.join(solara_template, 'brands')
    end

    def self.template_config
        platform = SolaraSettingsManager.instance.platform
        File.join(solara_template, 'config', "#{platform}_template_config.json")
    end

    def self.template_validation_config
        platform = SolaraSettingsManager.instance.platform
        File.join(root, 'core', 'doctor', 'validator', 'template', "#{platform}_template_validation_config.yml")
    end

    def self.solara_template_brands_json
        File.join(root, 'core', 'template', 'brands', 'brands.json')
    end

    def self.solara_template
        File.join(root, 'core', 'template')
    end

    def self.solara_aliases_json
        File.join(dot_solara, 'aliases', 'aliases.json')
    end

    def self.project_settings
        File.join(dot_solara, 'project_settings.json')
    end

    def self.solara_settings
        File.join(dot_solara, 'solara_settings.json')
    end

    def self.solara_version
        File.join(dot_solara, 'solara_version.json')
    end

    def self.solara_generated_aliases_unix
        File.join(ENV['HOME'], '.solara', 'aliases.sh')
    end

    def self.solara_generated_aliases_windows_command_prompt
        File.join(ENV['HOME'], '.solara', 'command_prompt_aliases.bat')
    end

    def self.solara_generated_aliases_powershell
        File.join(ENV['HOME'], '.solara', 'powershell_aliases.ps1')
    end

    def self.solara_aliases_readme
        File.join(dot_solara, 'aliases', 'README.md')
    end

    def self.android_launcher_icon(brand_key)
        paths = %w[mipmap-xxxhdpi mipmap-xxhdpi mipmap-xhdpi mipmap-mdpi mipmap-hdpi]

        paths.each do |path|
            full_path = File.join(android_brand_root(brand_key), 'res', path)
            return File.join(full_path, 'ic_launcher.png') if File.exist?(full_path)
        end

        nil # No existing path found
    end

    def self.launcher_icon(brand_key)
        case SolaraSettingsManager.instance.platform
        when Platform::Flutter
            return android_launcher_icon(brand_key)
        when Platform::Android
            return android_launcher_icon(brand_key)
        when Platform::IOS
            path = ios_brand_app_icon_image(brand_key)
            return path
        else
            raise ArgumentError, "Invalid platform: #{SolaraSettingsManager.instance.platform}"
        end
    end

    def self.ios_brand_app_icon(brand_key)
        File.join(ios_brand_xcassets(brand_key), 'AppIcon.appiconset')
    end

    def self.ios_brand_app_icon_image(brand_key)
        appicon_set_path = ios_brand_app_icon(brand_key)

        if appicon_set_path.nil?
            raise "Error: AppIcon.appiconset not found for brand #{brand_key}"
        end

        contents_json_path = File.join(appicon_set_path, 'Contents.json')

        unless File.exist?(contents_json_path)
            raise "Error: Contents.json not found in AppIcon.appiconset for brand #{brand_key}"
        end

        contents = JSON.parse(File.read(contents_json_path))

        largest_image = contents['images'].max_by do |img|
            size = img['size'].scan(/(\d+)x(\d+)/).first&.map(&:to_i)
            size ? size[0] * size[1] : 0
        end

        if largest_image
            File.join(appicon_set_path, largest_image['filename'])
        else
            raise "No images found in Contents.json for brand #{brand_key}"
        end
    end

    def self.app_xcconfig(name)
        case SolaraSettingsManager.instance.platform
        when Platform::Flutter
            return File.join(project_root, ios, 'Flutter', name)
        when Platform::IOS
            return File.join(xcode_project_directory, 'XCConfig', name)
        else
            raise ArgumentError, "Invalid platform: #{SolaraSettingsManager.instance.platform}"
        end
    end

    def self.xcode_project_directory
        Pathname.new(xcode_project).parent.to_s
    end

    def self.xcode_project
        path = ProjectSettingsManager.instance.value('xcodeproj', Platform::IOS)
        File.join(project_root, path)
    end

    def self.ios_brand_xcassets(brand_key)
        File.join(brands, brand_key, ios, 'xcassets')
    end


    def self.ios_brand_assets(brand_key)
        File.join(brands, brand_key, ios, 'assets')
    end

    def self.brand_xcconfig
        File.join(ios_project_root_artifacts, 'Brand.xcconfig')
    end

    def self.ios_project_fonts
        File.join(ios_project_root_artifacts, 'Fonts')
    end

    def self.android_project_fonts
        File.join(android_project_main_artifacts, 'font')
    end

    def self.flutter_project_fonts
        File.join(project_root, 'assets', 'solara_fonts')
    end

    def self.ios_project_root_artifacts
        case SolaraSettingsManager.instance.platform
        when Platform::Flutter
            return File.join(project_root, ios, 'Flutter', artifacts_dir_name_ios)
        when Platform::IOS
            return File.join(xcode_project_directory, artifacts_dir_name_ios)
        else
            raise ArgumentError, "Invalid platform: #{SolaraSettingsManager.instance.platform}"
        end
    end

    def self.project_info_plist_directory
        Pathname.new(info_plist).parent.to_s
    end

    def self.info_plist
        path = ProjectSettingsManager.instance.value('Info.plist', Platform::IOS)
        File.join(project_root, path)
    end

    def self.ios_project_assets_artifacts
        File.join(File.dirname(ios_project_xcassets), 'Assets.xcassets', artifacts_dir_name_ios)
    end

    def self.ios_project_xcassets
        path = ProjectSettingsManager.instance.value('Assets.xcassets', Platform::IOS)
        File.join(project_root, path)
    end

    def self.ios_project_original_app_icon
        File.join(ios_project_xcassets, 'AppIcon.appiconset')
    end

    def self.ios_project_artifacts_assets
        File.join(ios_project_root_artifacts, 'Assets')
    end

    def self.app_xcconfig_directory
        Pathname.new(app_xcconfig('Debug.xcconfig')).parent.to_s
    end

    def self.schema
        File.join(root, 'core', 'doctor', 'schema')
    end

    def self.brand_configurations_schema
        File.join(schema, 'brand_configurations.json')
    end

    def self.flutter_xcconfig_debug
        File.join(project_root, ios, 'Flutter', 'Debug.xcconfig')
    end

    def self.flutter_xcconfig_release
        File.join(project_root, ios, 'Flutter', 'Release.xcconfig')
    end

end