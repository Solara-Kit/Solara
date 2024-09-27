require 'fileutils'

class FolderCopier
    def initialize(source_path, destination_path)
        @source_path = source_path
        @destination_path = destination_path
    end

    def copy
        FileUtils.mkdir_p(@destination_path) unless File.exist?(@destination_path)
        copy_files_and_folders(@source_path, @destination_path)
        Solara.logger.debug("🚗 Copied\n\t↑ From: #{@source_path} \n\t↓ To:   #{@destination_path}")
    end

    private

    def copy_files_and_folders(source, destination)
        if File.file?(source)
            FileUtils.cp_r(source, destination)
        elsif File.directory?(source)
            Dir.foreach(source) do |item|
                next if item == '.' || item == '..'
                source_item_path = File.join(source, item)
                destination_item_path = File.join(destination, item)

                if File.directory?(source_item_path)
                    FileUtils.mkdir_p(destination_item_path) unless File.directory?(destination_item_path)
                    copy_files_and_folders(source_item_path, destination_item_path)
                else
                    FileUtils.cp_r(source_item_path, destination_item_path)
                end
            end
        else
            raise "Source is not a file or directory: #{source}"
        end
    end
end