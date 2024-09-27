require 'xcodeproj'
require 'plist'

class IOSPlistManager
    def initialize(project, info_plist_path)
        @project = project
        @info_plist_path = info_plist_path
    end

    def set_info_plist_in_build_settings
        path = FileManager.get_relative_path(FilePath.xcode_project_directory, @info_plist_path)
        main_target.build_configurations.each do |config|
            config.build_settings['INFOPLIST_FILE'] = path
        end
    end

    def add_fonts(font_names)
        font_manager = PlistFontManager.new(FilePath.info_plist)
        font_manager.add_fonts(font_names)
    end

    private

    def save_project
        @project.save
    end

    def main_target
        @project.targets.first
    end

end

