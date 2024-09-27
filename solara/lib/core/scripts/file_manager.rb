require 'find'

class FileManager
    def copy_files_recursively(source_dir, destination_dir)
        source_path = Pathname.new(source_dir).expand_path
        destination_path = Pathname.new(destination_dir).expand_path

        if Dir.exist?(source_path)
          Dir.glob(source_path.join('*')).each do |item|
            relative_path = Pathname.new(item).relative_path_from(source_path).to_s
            destination_item_path = destination_path.join(relative_path)

            if File.directory?(item)
              FileUtils.mkdir_p(destination_item_path)
              FileUtils.cp_r(item + '/.', destination_item_path) # Ensure to copy contents
            else
              FileUtils.mkdir_p(destination_item_path.dirname) # Create parent directory
              FileUtils.cp(item, destination_item_path)
            end

            Solara.logger.debug("🚗 Copied #{relative_path} \n\t↑ From: #{source_path} \n\t↓ To:   #{destination_path}")
          end
        else
          Solara.logger.failure("#{source_path} not found!")
        end
      end

    def delete_folders_by_prefix(directory, folder_prefix)
        # Get a list of all folders in the directory
        folders = Dir.entries(directory).select { |entry|
            File.directory?(File.join(directory, entry)) && entry.start_with?(folder_prefix)
        }

        # Delete each folder
        folders.each do |folder|
            folder_path = File.join(directory, folder)
            FileManager.delete_if_exists(folder_path)
            Solara.logger.debug("🧹 Deleted folder: #{folder_path}")
        end
    end

    def self.create_file_if_not_exist(file_path)
        unless File.exist?(file_path)
            FileUtils.mkdir_p(File.dirname(file_path))
            File.open(file_path, 'w') {}
            Solara.logger.debug("✨ Created file: #{file_path}")
        end
    end

    def self.create_files_if_not_exist(file_paths)
        file_paths.each do |file_path|
            create_file_if_not_exist(file_path)
        end
    end

    def self.find_file_extesion(extension)
        files = []
        Find.find(SolaraSettingsManager.instance.project_root) do |path|
            if FileTest.file?(path) && File.extname(path) == extension
                files << path
            end
        end
        files
    end

    def self.find_files_by_extension(directory, extension)
        Dir.glob(File.join(directory, "**", "*#{extension}"))
    end

    def self.find_files_by_name(directory, filename)
        # Ensure proper path formatting
        directory = File.expand_path(directory)

        # Generate the search pattern
        pattern = File.join(directory, "**", filename)

        # Output the pattern for debugging
        Solara.logger.debug("Searching for: #{pattern}")

        # Find and return matching files
        Dir.glob(pattern).to_a
      end

    def self.find_files_and_directories(root, name)
      # Ensure proper path formatting
      root = File.expand_path(root)

      # Generate the search pattern
      pattern = File.join(root, name)

      # Output the pattern for debugging
      Solara.logger.debug("Searching for: #{pattern}")

      # Use Dir.glob to find files and directories
      results = Dir.glob(pattern).select { |path| File.file?(path) || File.directory?(path) }

      # Output results for debugging
      Solara.logger.debug("Found: #{results}")

      results
    end

    def self.get_relative_path(root_dir, sub_dir)
        Pathname(sub_dir).relative_path_from(Pathname(root_dir)).to_s
    rescue
        sub_dir
    end

    def self.get_relative_path_to_root(sub_dir)
        Pathname(sub_dir).relative_path_from(Pathname(FilePath.project_root)).to_s
    rescue
        sub_dir
    end

    def self.get_folders(source)
        # Fetches only directories in the specified source directory
        Dir.glob(File.join(source, '*')).select { |path| File.directory?(path) }
    end

    def self.delete_if_exists(path)
        FileUtils.rm_rf(path) if File.exist?(path)
    end

end