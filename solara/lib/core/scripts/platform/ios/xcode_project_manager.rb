class XcodeProjectManager
    def initialize
    end

    def add_files_to_group(project, group, directory_path)
        Dir.foreach(directory_path) do |entry|
            next if entry == '.' || entry == '..' || entry == '.DS_Store'

            file_path = File.join(directory_path, entry)
            if File.directory?(file_path)
                Solara.logger.debug("Processing directory: #{file_path}")
                subgroup = group.groups.find { |g| g.name == entry } || group.new_group(entry)
                add_files_to_group(project, subgroup, file_path)
            else
                add_single_file_to_group(project, group, file_path)
            end
        end
    end

    def add_single_file_to_group(project, group, file_path)
        Solara.logger.debug("Adding new file: #{file_path}")
        file_name = File.basename(file_path, File.extname(file_path))

        existing_file = group.files.find { |f| File.basename(f.path, File.extname(f.path))&.downcase == file_name.downcase }
        existing_group = group.groups.find { |g| g.name&.downcase == file_name.downcase }
        existing_reference = existing_file || existing_group

        if existing_reference
            if existing_reference.is_a?(Xcodeproj::Project::Object::PBXFileReference)
                Solara.logger.debug("Ignoring file: #{file_path} (Existing file reference: #{existing_reference.path})")
            else
                Solara.logger.debug("Ignoring file: #{file_path} (Existing group with same name: #{existing_reference.name})")
            end
            return nil
        else
            file_reference = group.new_file(file_path)
            Solara.logger.debug("Adding new file: #{file_path} (File reference: #{file_reference.uuid})")

            # Add the file to the project's main target if it's a source file
            if %w[.swift .m .mm .c .cpp].include?(File.extname(file_path).downcase)
                target = project.targets.first
                target.add_file_references([file_reference])
                Solara.logger.debug("  Added to target: #{target.name}")
            end

            file_reference
        end
    end
    def self.set_base_xcconfigs(project, xcconfigs)
        # Iterate through all build configurations in the target
        project.targets.first.build_configurations.each do |config|
            # Find the matching XCConfig from the array
            matching_xcconfig = xcconfigs.find { |xc| config.name.downcase.include?(xc[:type].downcase) }

            # If no matching XCConfig found, use debug as base
            matching_xcconfig ||= xcconfigs.find { |xc| xc[:type].downcase == 'debug' }

            if matching_xcconfig
                set_xcconfig(project, config, matching_xcconfig)
            else
                Solara.logger.warn("Warning: No matching XCConfig found for #{config.name} configuration, and no Debug XCConfig available")
            end
        end

        Solara.logger.debug("Base XCConfig files have been set for all build configurations.")
    end
    def self.set_xcconfig(project, config, xcconfig)
        # Find the existing file reference or create a new one if it doesn't exist
        file_reference = project.reference_for_path(xcconfig[:path])
        if file_reference
            config.base_configuration_reference = file_reference
            Solara.logger.debug("Set #{xcconfig[:type]} XCConfig for #{config.name} configuration")
        else
            # If the file reference doesn't exist, create a new one
            new_file_reference = project.new_file(xcconfig[:path])
            config.base_configuration_reference = new_file_reference
            Solara.logger.debug("Created and set new #{xcconfig[:type]} XCConfig for #{config.name} configuration")
        end
    end

    def add_file_to_root(project, file_path)
        Solara.logger.debug("Adding file to root: #{file_path}")

        root_group = project.main_group
        file_name = File.basename(file_path, File.extname(file_path))

        existing_file = root_group.files.find { |f| File.basename(f.path, File.extname(f.path))&.downcase == file_name.downcase }

        if existing_file
            Solara.logger.debug("Ignoring file: #{file_path} (Existing file reference: #{existing_file.path})")
            return nil
        else
            file_reference = root_group.new_file(file_path)
            Solara.logger.debug("Added new file to root: #{file_path} (File reference: #{file_reference.uuid})")

            # Add the file to the project's main target if it's a source file
            if %w[.swift .m .mm .c .cpp].include?(File.extname(file_path).downcase)
                target = project.targets.first
                target.add_file_references([file_reference])
                Solara.logger.debug("  Added to target: #{target.name}")
            end

            file_reference
        end
    end

    def self.add_file_near_info_plist(project, file_path)
        Solara.logger.debug("Adding file near Info.plist: #{file_path}")

        # Find the Info.plist file path
        info_plist_path = project.targets.first.build_configurations.first.build_settings['INFOPLIST_FILE']
        return Solara.logger.warn("No Info.plist file found for the target") unless info_plist_path

        # Get the directory of the Info.plist file
        info_plist_dir = File.dirname(info_plist_path)

        target_file_path = File.basename(file_path)
        infoplist_group = info_plist_dir === '.' ? project.main_group : find_group_by_path(project, [info_plist_dir])

        # Check if a file with the same name already exists in the target directory
        existing_file = infoplist_group.files.find { |f| f.path == target_file_path }

        if existing_file
          Solara.logger.debug("Ignoring file: #{file_path} (Existing file reference: #{existing_file.path})")
          return nil
        else
          # Add the file to the main group, which corresponds to the directory of Info.plist
          file_reference = infoplist_group.new_file(target_file_path)
          Solara.logger.debug("Added new file near Info.plist: #{file_path} (File reference: #{file_reference.uuid})")

          # Add the file to the project's main target as a resource
          target = project.targets.first

          # Create a new build file
          build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
          build_file.file_ref = file_reference

          # Add the build file to the target's resources build phase
          resources_build_phase = target.resources_build_phase
          resources_build_phase.add_file_reference(file_reference)

          Solara.logger.debug("  Added to target: #{target.name}")
          Solara.logger.debug("  Added to PBXBuildFile section as a resource")

          file_reference
        end
      end
def self.find_group_by_path(project, paths)
    current_group = project.main_group

    paths.each do |path|
        current_group = current_group.children.find { |child|
            child.is_a?(Xcodeproj::Project::Object::PBXGroup) && child.path == path
        }
        return nil unless current_group
    end
    current_group
  end


end