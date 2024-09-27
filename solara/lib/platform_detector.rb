require 'find'

class PlatformDetector
    def initialize
        @project_path = SolaraSettingsManager.instance.project_root
    end

    def platform
        Solara.logger.start_step("Detecting current platform")
        detected_platform = detect

        if detected_platform != Platform::Unknown
            Solara.logger.info("👀 Detected platform: #{detected_platform}")
        else
            Solara.logger.failure("Unable to detect platfrom")
            return enter_correct_platform
        end

        print "Is this #{detected_platform.upcase} project? (y/n): ".yellow

        loop do
            response = STDIN.gets.chomp.downcase
            if response == 'y' || response.empty?
                Solara.logger.end_step("Detecting current platform")
                return detected_platform
            elsif response == 'n'
                return enter_correct_platform
            else
                Solara.logger.failure("Invalid input. Please enter 'y' or 'n'.")
            end
        end
    end

    private

    def enter_correct_platform
        loop do
            print "Enter the platform (#{Platform.all.join(', ')}): ".green
            user_input = STDIN.gets.chomp.downcase
            if Platform.all.map(&:downcase).include?(user_input)
                Solara.logger.end_step("Detecting current platform")
                return user_input
            else
                Solara.logger.failure("Invalid platform. Please enter one of: #{Platform.all.join(', ')}")
            end
        end
    end

    def detect
        if flutter?
            Platform::Flutter
        elsif ios?
            Platform::IOS
        elsif android?
            Platform::Android
        else
            Platform::Unknown
        end
    end

    def flutter?
        flutter_config_file = File.join(@project_path, 'pubspec.yaml')
        flutter_main_file = File.join(@project_path, 'lib', 'main.dart')
        File.exist?(flutter_config_file) && File.exist?(flutter_main_file)
    end

    def ios?
        ios_project_files = []
        Find.find(@project_path) do |path|
            if File.directory?(path) && (path.end_with?('.xcodeproj') || path.end_with?('.xcworkspace'))
                ios_project_files << path
                Find.prune # Stop searching further in this directory
            end
        end
        !ios_project_files.empty?
    end

    def android?
        app_build_gradle = File.join(@project_path, 'app', 'build.gradle')
        app_build_gradle_kts = File.join(@project_path, 'app', 'build.gradle.kts')
        gradle_properties = File.join(@project_path, 'gradle.properties')
        (File.exist?(app_build_gradle) || File.exist?(app_build_gradle_kts)) && File.exist?(gradle_properties)
    end
end