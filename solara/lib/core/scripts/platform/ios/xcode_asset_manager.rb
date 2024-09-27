require 'fileutils'
require 'json'

class XcodeAssetManager
  def initialize(asset_catalog_path)
    @asset_catalog_path = asset_catalog_path
  end

  def add(source)
        # Fetches only files in the specified source directory
        Dir.glob(File.join(source, '*.{png,jpg,jpeg,svg,heic,pdf}')).each do |file_path|
          if File.file?(file_path) # Ensure it's a file and not a directory
                filename_without_extension = File.basename(file_path, File.extname(file_path))
                add_image(filename_without_extension, file_path, '1x')
            end
        end
    end
    
  def add_image(image_name, image_path, scale = '1x')
    # Create the image set directory if it doesn't exist
    image_set_path = File.join(@asset_catalog_path, "#{image_name}.imageset")
    FileUtils.mkdir_p(image_set_path)

    # Copy the image file to the image set directory
    destination_path = File.join(image_set_path, "#{image_name}@#{scale}.png")
    FileUtils.cp(image_path, destination_path)

    # Update or create the Contents.json file
    contents_json_path = File.join(image_set_path, 'Contents.json')
    contents = if File.exist?(contents_json_path)
                 JSON.parse(File.read(contents_json_path))
               else
                 { "images" => [], "info" => { "version" => 1, "author" => "solara" } }
               end

    # Add or update the image entry
    image_entry = {
      "idiom" => "universal",
      "filename" => "#{image_name}@#{scale}.png",
      "scale" => scale
    }

    existing_entry = contents["images"].find { |img| img["scale"] == scale }
    if existing_entry
      existing_entry.merge!(image_entry)
    else
      contents["images"] << image_entry
    end

    # Write the updated Contents.json
    File.write(contents_json_path, JSON.pretty_generate(contents))

    Solara.logger.debug("XcodeAssetManager: Image '#{image_name}' added successfully at scale #{scale}.")
  end
end