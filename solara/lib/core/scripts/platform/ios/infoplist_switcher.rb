$LOAD_PATH.unshift(File.expand_path(__dir__))

class InfoPlistSwitcher
    def initialize(project_path, brand_key)
        @project_path = project_path
        @brand_key = brand_key
        @project = Xcodeproj::Project.open(@project_path)
    end

    def switch
        copy_string_catalog
        update_info_plist
        @project.save
        Solara.logger.debug("Switched #{FilePath.info_plist} successfully.")
    end

    private

    def copy_string_catalog
        # Remove from project before copying
        project_infoplist_string_catalog = FilePath.project_infoplist_string_catalog
        if File.exist?(project_infoplist_string_catalog)
            FileManager.delete_if_exists(project_infoplist_string_catalog)
            Solara.logger.debug("Deleted #{project_infoplist_string_catalog} successfully.")
        end

        source = FilePath.brand_infoplist_string_catalog(@brand_key)
        destination = FilePath.project_info_plist_directory
        FolderCopier.new(source, destination).copy

        # Add reference to XcodeProject
        XcodeProjectManager.add_file_near_info_plist(@project, project_infoplist_string_catalog)
    end

    def update_info_plist
        info_plist_path = FilePath.info_plist
        manager = IOSPlistManager.new(@project, info_plist_path)
        manager.set_info_plist_in_build_settings

        xcconfig_values = {
            'CFBUNDLE_DISPLAY_NAME' => "$(CFBUNDLE_DISPLAY_NAME)",
            'CFBUNDLE_NAME' => "$(CFBUNDLE_NAME)",
            'PRODUCT_NAME' => "$(PRODUCT_NAME)",
            'PRODUCT_BUNDLE_IDENTIFIER' => "$(PRODUCT_BUNDLE_IDENTIFIER)",
            'MARKETING_VERSION' => "$(MARKETING_VERSION)",
            'BUNDLE_VERSION' => "$(BUNDLE_VERSION)"
        }

        info_plist = Xcodeproj::Plist.read_from_path(info_plist_path)
        info_plist[InfoPListKey::BUNDLE_DISPLAY_NAME] = xcconfig_values['CFBUNDLE_DISPLAY_NAME']
        info_plist[InfoPListKey::BUNDLE_NAME] = xcconfig_values['CFBUNDLE_NAME']
        info_plist['CFBundleIdentifier'] = xcconfig_values['PRODUCT_BUNDLE_IDENTIFIER']
        info_plist['CFBundleShortVersionString'] = xcconfig_values['MARKETING_VERSION']
        info_plist['CFBundleVersion'] = xcconfig_values['BUNDLE_VERSION']

        Xcodeproj::Plist.write_to_path(info_plist, info_plist_path)
    end

end