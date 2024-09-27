$LOAD_PATH.unshift(File.expand_path(__dir__))

class XcodeProjectSwitcher
    def initialize(project_path, brand_key)
        @project_path = project_path
        @brand_key = brand_key
        @project = Xcodeproj::Project.open(@project_path)
        @target = @project.targets.first
        @platform = SolaraSettingsManager.instance.platform
    end

    def switch
        update_xcode_target_settings
        add_artifacts_group
        update_debug_and_release_xcconfig
        @project.save
        Solara.logger.debug("Switched #{@project_path} Successfully.")
    end

    private

    def update_xcode_target_settings
        @target.build_configurations.each do |config|
            config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = '$(PRODUCT_BUNDLE_IDENTIFIER)'
            config.build_settings['MARKETING_VERSION'] = '$(MARKETING_VERSION)'
            config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = '$(APPICON_NAME)'
            config.build_settings['PRODUCT_NAME'] = '$(PRODUCT_NAME)'

            # We need to apply code signing only if the user has provided its config
            path = FilePath.brand_signing(@brand_key, Platform::IOS)
            signing = JSON.parse(File.read(path))
            unless signing['PROVISIONING_PROFILE_SPECIFIER'].empty?
                config.build_settings['CODE_SIGN_IDENTITY'] = '$(CODE_SIGN_IDENTITY)'
                config.build_settings['DEVELOPMENT_TEAM'] = '$(DEVELOPMENT_TEAM)'
                config.build_settings['PROVISIONING_PROFILE_SPECIFIER'] = '$(PROVISIONING_PROFILE_SPECIFIER)'
                config.build_settings['CODE_SIGN_STYLE'] = '$(CODE_SIGN_STYLE)'
                config.build_settings['CODE_SIGN_ENTITLEMENTS'] = '$(CODE_SIGN_ENTITLEMENTS)'
            end

            # We need to apply APL_MRCH_ID only if the user has provided its config
            path = FilePath.ios_config(@brand_key)
            ios_config = JSON.parse(File.read(path))
            merchant_id = ios_config['APL_MRCH_ID']
            unless merchant_id.nil? || merchant_id.empty?
                config.build_settings['APL_MRCH_ID'] = '$(APL_MRCH_ID)'
            end
        end
    end

    def update_debug_and_release_xcconfig
        debug_xcconfig_path = FilePath.app_xcconfig('Debug.xcconfig')
        release_xcconfig_path = FilePath.app_xcconfig('Release.xcconfig')

        create_xcconfigs_and_add_to_project(debug_xcconfig_path, release_xcconfig_path)
        set_base_xcconfigs(debug_xcconfig_path, release_xcconfig_path)
    end

    def create_xcconfigs_and_add_to_project(debug_xcconfig_path, release_xcconfig_path)
        FileManager.create_files_if_not_exist([debug_xcconfig_path, release_xcconfig_path])
        base_xcconfig_name = "#{FilePath.artifacts_dir_name_ios}/Brand.xcconfig"

        case @platform
        when Platform::Flutter
            # Nothing
        when Platform::IOS
            group_name = 'XCConfig'
            config_group = @project.groups.find { |group| group.name == group_name }
            config_group = @project.new_group(group_name) if config_group.nil?
            add_files_to_group(config_group, FilePath.app_xcconfig_directory)
        else
            raise ArgumentError, "Invalid platform: #{@platform}"
        end

        File.open(debug_xcconfig_path, "w") { |file| file.write("#include \"#{base_xcconfig_name}\"\n") }
        File.open(release_xcconfig_path, "w") { |file| file.write("#include \"#{base_xcconfig_name}\"\n") }
    end

    def set_base_xcconfigs(debug_xcconfig_path, release_xcconfig_path)
        xcconfigs = [
            { type: 'Debug', path: debug_xcconfig_path },
            { type: 'Release', path: release_xcconfig_path },
        ]
        XcodeProjectManager.set_base_xcconfigs(
            @project,
            xcconfigs
        )
    end

    def add_artifacts_group
        artifacts_dir_name = FilePath.artifacts_dir_name_ios
        
        case @platform
        when Platform::Flutter
            flutter_group = @project.groups.find { |group| group.name == 'Flutter' }
            artifacts_group = flutter_group.groups.find { |group| group.name == artifacts_dir_name }
            artifacts_group = flutter_group.new_group(artifacts_dir_name) if artifacts_group.nil?
            add_files_to_group(artifacts_group, FilePath.ios_project_root_artifacts)
        when Platform::IOS
            artifacts_group = @project.groups.find { |group| group.name == artifacts_dir_name }
            artifacts_group = @project.new_group(artifacts_dir_name) if artifacts_group.nil?
            add_files_to_group(artifacts_group, FilePath.ios_project_root_artifacts)
        else
            raise ArgumentError, "Invalid platform: #{@platform}"
        end
    end

    def add_files_to_group(group, directory_path)
        XcodeProjectManager.new.add_files_to_group(@project, group, directory_path)
    end

end