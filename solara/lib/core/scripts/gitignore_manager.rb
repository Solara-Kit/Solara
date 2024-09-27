class GitignoreManager
    def initialize(gitignore_path = '.gitignore')
        @gitignore_path = gitignore_path.end_with?('.gitignore') ? gitignore_path : File.join(gitignore_path, '.gitignore')
        create_gitignore_if_not_exists
    end

    def self.ignore
        Solara.logger.start_step("Exclude Brand-Generated Files and Folders from Git")

        items = [
            "# Generated by Solara. Ignore redundant brand specific changes.",
            "**/#{FilePath.artifacts_dir_name}/",
            "**/#{FilePath.artifacts_dir_name_ios}/",
            "solara/brand/brands/current_brand.json",
            ".solara/aliases/",
            ".solara/solara_settings.json",
            "solara_fonts",
         ]

        if Platform.is_flutter || Platform.is_ios
            items << FileManager.get_relative_path_to_root(FilePath.project_infoplist_string_catalog)
            # The excluded InfoPlist.xcstrings maybe at the root. In this case we have to avoid ignoring the brands files.
            items << '!solara/brand/brands/**/InfoPlist.xcstrings'
        end

        GitignoreManager.new(FilePath.project_root).add_items(items)
        Solara.logger.end_step("Exclude Brand-Generated Files and Folders from Git")
    end
        
    def add_items(items)
        items.each do |item|
            add_item(item)
        end
    end

    def add_item(item)
        existing_items = read_gitignore

        if existing_items.include?(item)
            Solara.logger.debug("'#{item}' already exists in .gitignore")
        else
            File.open(@gitignore_path, 'a') do |file|
                file.puts(item)
            end
            Solara.logger.debug("Added '#{item}' to .gitignore")
        end
    end

    private

    def create_gitignore_if_not_exists
        unless File.exist?(@gitignore_path)
            File.open(@gitignore_path, 'w') do |file|
                file.puts("# Generated by Solara")
                file.puts("# Git ignore file")
                file.puts("# Add items to ignore below")
            end
            Solara.logger.debug("Created new .gitignore file at #{@gitignore_path}")
        end
    end

    def read_gitignore
        File.readlines(@gitignore_path).map(&:chomp)
    end
end