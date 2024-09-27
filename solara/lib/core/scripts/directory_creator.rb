class DirectoryCreator
    def self.create_directories(directories, delete_if_exists = false)
        directories.each do |dir|
            create_directory(dir, delete_if_exists)
        end
    end

    private

    def self.create_directory(dir, delete_if_exists)
        if Dir.exist?(dir)
            if delete_if_exists
                FileManager.delete_if_exists(dir)
                Solara.logger.debug("🧹 Deleted directory: #{dir}")
                Dir.mkdir(dir)
            end
        else
            FileUtils.mkdir_p(dir)
        end
        Solara.logger.debug("✨  Created directory: #{dir}")
    end
end