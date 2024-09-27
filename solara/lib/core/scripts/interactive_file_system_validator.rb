Dir.glob("#{__dir__}/*.rb").each { |file| require file }

require 'json'
require 'fileutils'

class InteractiveFileSystemValidator
    def initialize(project_root, settings_manager)
        @project_root = project_root
        @settings_manager = settings_manager
    end

    def start(file_system)
        validate(file_system)
    end

    def validate(file_system)
        file_system.each do |item|
            key = item[:key]
            name = item[:name]
            type = item[:type]
            platform = item[:platform]
            item_path = item.fetch(:path, '')
            recursive = item.fetch(:recursive, true)

            value = @settings_manager.value(key, platform)

            if value
                # Check if the item exists and is of the correct type
                if type == 'file' && !File.file?(value)
                    Solara.logger.failure("Missing file: #{key} (#{value})")
                    validate_required_item(item)
                elsif type == 'folder' && !File.directory?(value)
                    Solara.logger.failure("Missing folder: #{key} (#{value})")
                    validate_required_item(item)
                end
            else
                ignored = [
                'macos/',
                'solara/',
                "#{FilePath.artifacts_dir_name}/",
                "#{FilePath.artifacts_dir_name_ios}/",
                'Pods/',
                'build/']

                root = File.join(@project_root, item_path)
                paths = if recursive
                            FileManager.find_files_by_name(root, name)
                        else
                            FileManager.find_files_and_directories(root, name)
                        end

                paths = paths.map { |path| FileManager.get_relative_path(@project_root, path) }
                             .reject { |path| ignored.any? { |ignored_path| path.include?(ignored_path) } }

                case paths.size
                when 0
                    Solara.logger.failure("Missing #{type}: #{key}")
                    validate_required_item(item)
                when 1
                    @settings_manager.add(key, paths.first, platform)

                    Solara.logger.debug("Added #{type}: #{key} (#{paths.first})")
                else
                    Solara.logger.failure("Found multiple paths for #{key}:\n\t- #{paths.join("\n\t- ")}")
                    validate_required_item(item)
                end
            end
        end
    end

    private

    def validate_required_item(item)
        item_key = item[:key]
        item_type = item[:type]
        platform = item[:platform]
        item_path = ''

        loop do
            item_path = get_path_from_user(item_key, item_type)
            break if validate_item(item_path, item_key, item_type)
        end
        value = FileManager.get_relative_path(@project_root, item_path)
        @settings_manager.add(item_key, value, platform)
    end

    def validate_item(item_path, item_name, item_type)
        return false if item_path.nil? || !item_path.end_with?(item_name)

        case item_type
        when 'file'
            if File.file?(item_path)
                Solara.logger.debug("File exists: #{item_path}")
                true
            else
                Solara.logger.failure("File does not exist: #{item_path}")
                false
            end
        when 'folder'
            if File.directory?(item_path)
                true
            else
                Solara.logger.failure("Folder does not exist: #{item_path}")
                false
            end
        else
            Solara.logger.failure("Invalid item type: #{item_type}")
            false
        end
    end

    def get_path_from_user(item_key, item_type)
        print "Enter the relative path for #{item_key}): "
        STDIN.gets.chomp
    end
end