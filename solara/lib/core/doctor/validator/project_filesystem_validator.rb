class ProjectFileSystemValidator

    def initialize
        @project_root = SolaraSettingsManager.instance.project_root
        @platform = SolaraSettingsManager.instance.platform
    end

    def validate
        file_system = project_filesystem
        manager = InteractiveFileSystemValidator.new(@project_root, ProjectSettingsManager.instance)
        manager.start(file_system)
    end

    def project_filesystem
        case @platform
        when Platform::Flutter
            android_file_system + ios_file_system
        when Platform::IOS
            ios_file_system
        when Platform::Android
            android_file_system
        else
            raise ArgumentError, "Invalid platform: #{@platform}"
        end
    end

    def android_file_system
        [
            {
                name: FilePath.gradle_name,
                path: File.join(FilePath.android_project_relative_root),
                key: 'build.gradle',
                type: 'file',
                recursive: false,
                platform: Platform::Android
            },
            {
                name: FilePath.gradle_name,
                path: File.join(FilePath.android_project_relative_root, 'app'),
                key: 'app/build.gradle',
                type: 'file',
                recursive: false,
                platform: Platform::Android,
            }
        ]
    end

    def ios_file_system
        [
            {
                name: '*.xcodeproj',
                key: 'xcodeproj',
                type: 'folder',
                platform: Platform::IOS,
            },
            {
                name: 'Assets.xcassets',
                key: 'Assets.xcassets',
                type: 'folder',
                platform: Platform::IOS,
            },
            {
                name: 'Info.plist',
                key: 'Info.plist',
                type: 'file',
                platform: Platform::IOS,
            }
        ]
    end
end