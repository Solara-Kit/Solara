Dir[File.expand_path('../scripts/*.rb', __dir__)].each { |file| require_relative file }

require 'json'
require 'rbconfig'

class AliasManager
    def initialize
        case RbConfig::CONFIG['host_os']
        when /mswin|mingw|cygwin/
            @generator = WindowsAliasGenerator.new
        when /darwin|mac os|linux/
            @generator = UnixAliasGenerator.new
        else
          Solara.logger.fatal("Unsupported operating system. Aliases can't be generated.")
        end
    end

    def start
        Solara.logger.start_step("Generate terminal command aliases")
        add_brand_aliases(BrandsManager.instance.brands_list)

        common_aliases =
        [
            ["solara_dashboard", "bundle exec solara dashboard"],
            ["solara_doctor", "bundle exec solara doctor"],
            ["solara_status", "bundle exec solara status"],
        ]
        add_common_aliases(common_aliases)

        generate
        save_aliases_to_json
        generate_readme

        TerminalSetup.new.run

        Solara.logger.end_step("Generate terminal command aliases")
    end

    private

    def add_brand_aliases(brands)
        @generator.add_brand_aliases(brands)
    end

    def add_common_aliases(common_aliases)
        @generator.add_common_aliases(common_aliases)
    end

    def generate
        @generator.generate
    end

    def generate_readme
        @generator.generate_readme
    end

    def save_aliases_to_json
        @generator.save_aliases_to_json
    end

    def self.aliases_json
        path = FilePath.solara_aliases_json
        JSON.parse(File.read(path))
    end

    private

    def windows?

        # Check for Windows OS
        !!(RUBY_PLATFORM =~ /mingw|mswin/)
    end
end

class AliasGenerator
    def initialize
        @brand_aliases = {}
        @common_aliases = []
    end

    def add_brand_aliases(brands)
        alias_templates = [
            ["solara_export_{brand_key}", "bundle exec solara export --brand_keys {brand_key}"],
            ["solara_offboard_{brand_key}", "bundle exec solara offboard -k {brand_key}"],
            ["solara_switch_{brand_key}", "bundle exec solara switch -k {brand_key}"],
            ["solara_doctor_{brand_key}", "bundle exec solara doctor -k {brand_key}"],
            ["solara_dashboard_{brand_key}", "bundle exec solara dashboard -k {brand_key}"]
        ]

        brands.each do |app|
            brand_key = app['key']
            @brand_aliases[brand_key] = []
            alias_templates.each do |alias_name, command|
                alias_name = alias_name.gsub('{brand_key}', brand_key)
                command = command.gsub('{brand_key}', brand_key)
                @brand_aliases[brand_key] << [alias_name, command]
            end
        end
    end

    def add_common_aliases(common_aliases)
        @common_aliases = common_aliases
    end

    def generate_readme
        File.open(@readme_file, 'w') do |file|
            file.puts "# Aliases"
            file.puts
            file.puts "This document provides an overview of all available aliases."
            file.puts

            if @common_aliases.any?
                file.puts "## Common Aliases"
                file.puts
                @common_aliases.each do |value|
                    file.puts "- `#{value[0]}`: `#{value[1]}`"
                end
            end

            file.puts

            @brand_aliases.each do |brand_name, brand_aliases|
                file.puts "## #{brand_name}"
                file.puts
                brand_aliases.each do |alias_name, command|
                    file.puts "- `#{alias_name}`: `#{command}`"
                end
                file.puts
            end
        end
        Solara.logger.debug("README.md has been generated in #{@readme_file}")
    end

    def save_aliases_to_json
        json_data = {
            "common_aliases" => @common_aliases,
            "brand_aliases" => @brand_aliases
        }

        File.open(@json_file, 'w') do |file|
            file.puts JSON.pretty_generate(json_data)
        end
        Solara.logger.debug("Aliases have been saved in JSON format in #{@json_file}")
    end
end

class UnixAliasGenerator < AliasGenerator
    def initialize
        super()
        @output_file = FilePath.solara_generated_aliases_unix
        @readme_file = FilePath.solara_aliases_readme
        @json_file = FilePath.solara_aliases_json
        FileManager.create_file_if_not_exist(@output_file)
        FileManager.create_file_if_not_exist(@readme_file)
        FileManager.create_file_if_not_exist(@json_file)
    end

    def generate
        existing_content = File.exist?(@output_file) ? File.read(@output_file) : ""
        new_content = []

        new_content << "#!/bin/bash" if existing_content.empty?

        add_common_aliases_to_file(existing_content, new_content)
        add_brand_aliases_to_file(existing_content, new_content)

        if new_content.any? && !(new_content.size == 1 && new_content.first == "#!/bin/bash")
            File.open(@output_file, 'a') do |file|
                file.puts new_content
            end
            Solara.logger.debug("Unix aliases have been appended to #{@output_file}")
        else
            Solara.logger.debug("No new Unix aliases to add to #{@output_file}")
        end
    end

    private

    def add_common_aliases_to_file(existing_content, new_content)
        common_aliases_added = false
        @common_aliases.each do |value|
            alias_line = "alias #{value[0]}='#{value[1]}'"
            unless existing_content.include?(alias_line)
                new_content << "# Common Aliases" unless common_aliases_added
                common_aliases_added = true
                new_content << alias_line
            end
        end
    end

    def add_brand_aliases_to_file(existing_content, new_content)
        brand_aliases_added = false
        @brand_aliases.each do |brand_name, brand_aliases|
            brand_aliases_for_this_brand_added = false
            brand_aliases.each do |alias_name, command|
                alias_line = "alias #{alias_name}='#{command}'"
                unless existing_content.include?(alias_line)
                    unless brand_aliases_added
                        brand_aliases_added = true
                    end
                    unless brand_aliases_for_this_brand_added
                        new_content << "" # Add a new line before each brand name
                        new_content << "# #{brand_name}"
                        brand_aliases_for_this_brand_added = true
                    end
                    new_content << alias_line
                end
            end
        end
        new_content.reject!(&:empty?) if new_content.size == 1
    end
end

class WindowsAliasGenerator < AliasGenerator
    def initialize
        super()
        @cmd_output_file = FilePath.solara_generated_aliases_windows_command_prompt
        @ps_output_file = FilePath.solara_generated_aliases_powershell
        @readme_file = FilePath.solara_aliases_readme
        @json_file = FilePath.solara_aliases_json
        FileManager.create_file_if_not_exist(@cmd_output_file)
        FileManager.create_file_if_not_exist(@ps_output_file)
        FileManager.create_file_if_not_exist(@readme_file)
        FileManager.create_file_if_not_exist(@json_file)
    end

    def generate
        generate_cmd_file
        generate_powershell_file
    end

    private

    def generate_cmd_file
        existing_content = File.exist?(@cmd_output_file) ? File.read(@cmd_output_file) : ""
        new_content = []

        new_content << "@echo off" if existing_content.empty?

        add_common_aliases_to_file(existing_content, new_content, :cmd)
        add_brand_aliases_to_file(existing_content, new_content, :cmd)

        if new_content.any? && !(new_content.size == 1 && new_content.first == "@echo off")
            File.open(@cmd_output_file, 'a') do |file|
                file.puts new_content
            end
            Solara.logger.debug("Windows Command Prompt aliases have been appended to #{@cmd_output_file}")
        else
            Solara.logger.debug("No new Windows Command Prompt aliases to add to #{@cmd_output_file}")
        end
    end

    def generate_powershell_file
        existing_content = File.exist?(@ps_output_file) ? File.read(@ps_output_file) : ""
        new_content = []

        add_common_aliases_to_file(existing_content, new_content, :powershell)
        add_brand_aliases_to_file(existing_content, new_content, :powershell)

        if new_content.any?
            File.open(@ps_output_file, 'a') do |file|
                file.puts new_content
            end
            Solara.logger.debug("PowerShell aliases have been appended to #{@ps_output_file}")
        else
            Solara.logger.debug("No new PowerShell aliases to add to #{@ps_output_file}")
        end
    end

    def add_common_aliases_to_file(existing_content, new_content, shell_type)
        common_aliases_added = false
        @common_aliases.each do |alias_name, command|
            alias_line = shell_type == :cmd ? "doskey #{alias_name}=#{command} $*" : "function #{alias_name} { & #{command} }"
            unless existing_content.include?(alias_line)
                new_content << (shell_type == :cmd ? "REM Common Aliases" : "# Common Aliases") unless common_aliases_added
                common_aliases_added = true
                new_content << alias_line
            end
        end
    end

    def add_brand_aliases_to_file(existing_content, new_content, shell_type)
        brand_aliases_added = false
        @brand_aliases.each do |brand_name, brand_aliases|
            brand_aliases_for_this_brand_added = false
            brand_aliases.each do |alias_name, command|
                alias_line = shell_type == :cmd ? "doskey #{alias_name}=#{command} $*" : "function #{alias_name} { & #{command} }"
                unless existing_content.include?(alias_line)
                    unless brand_aliases_added
                        brand_aliases_added = true
                    end
                    unless brand_aliases_for_this_brand_added
                        new_content << "" # Add a new line before each brand name
                        new_content << (shell_type == :cmd ? "REM #{brand_name}" : "# #{brand_name}")
                        brand_aliases_for_this_brand_added = true
                    end
                    new_content << alias_line
                end
            end
        end
        new_content.reject!(&:empty?) if new_content.size == 1
    end
end