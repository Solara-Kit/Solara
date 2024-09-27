Dir[File.expand_path('scripts/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('../template/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('platform/android/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('platform/ios/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('platform/flutter/*.rb', __dir__)].each { |file| require_relative file }
class BrandFontSwitcher
def initialize(brand_key)
    @brand_key = brand_key
    @fonts_path = FilePath.brand_fonts
    @font_files = Dir.glob(File.join(@fonts_path, '*.{ttf,otf}'))
    Solara.logger.end_step("Switch Info.plist")
end

def switch
    Solara.logger.header("Switch Fonts")

    case SolaraSettingsManager.instance.platform
    when Platform::Flutter
      FlutterFontSwitcher.new(@brand_key, @font_files).switch
      AndroidFontSwitcher.new(@brand_key, @font_files).switch
      IOSFontSwitcher.new(@brand_key, @font_files).switch
    when Platform::Android
      AndroidFontSwitcher.new(@brand_key, @font_files).switch
    when Platform::IOS
      IOSFontSwitcher.new(@brand_key, @font_files).switch
    else
      raise ArgumentError, "Invalid platform: #{SolaraSettingsManager.instance.platform}"
    end
    end
end

class FlutterFontSwitcher
    def initialize(brand_key, font_files)
        @brand_key = brand_key
        @font_files = font_files
    end

    def switch
        Solara.logger.start_step("Switch Flutter fonts")
        destination = FilePath.flutter_project_fonts
        copy_fonts(destination)

        add_fonts_to_pubspec
        Solara.logger.end_step("Switch Flutter fonts")
    end

    private

    def add_fonts_to_pubspec
        yaml_manager = YamlManager.new(FilePath.pub_spec_yaml)
        font_families = Hash.new { |hash, key| hash[key] = [] }

        font_names = @font_files.map { |file| File.basename(file) }
        font_names.each do |font_file|
          base_name = File.basename(font_file, File.extname(font_file))
          family_name = base_name.split('-').first
          font_families[family_name] << font_file
        end

        font_families.each do |family_name, files|
          assets = files.map { |file| { 'asset' => "assets/solara_fonts/#{file}" } }
          yaml_manager.add_font(family_name, assets)
        end
    end

    def copy_fonts(destination)
      FontCopier.new.copy(destination, @font_files)
    end
end

class AndroidFontSwitcher
    def initialize(brand_key, font_files)
      @brand_key = brand_key
      @font_files = font_files
    end

    def switch
      Solara.logger.start_step("Switch Android fonts")
      destination = FilePath.android_project_fonts
      copy_fonts(destination)
      rename_fonts_in_directory(FilePath.android_project_fonts)
      Solara.logger.end_step("Switch Android fonts")
    end

    private

    def rename_fonts_in_directory(directory)
      Dir.foreach(directory) do |file|
        next if file == '.' || file == '..' # Skip current and parent directory entries

        old_path = File.join(directory, file)
        if File.file?(old_path)
          new_name = sanitize_font_name(file)
          new_path = File.join(directory, new_name)

          # Rename the file if the new name is different
          unless old_path == new_path
            FileUtils.mv(old_path, new_path)
            Solara.logger.debug("Renamed: #{file} -> #{new_name}")
          end
        end
      end
    end

    def sanitize_font_name(font_name)
      # Convert to lowercase
      sanitized_name = font_name.downcase
      # Replace spaces with underscores
      sanitized_name.gsub!('-', '_')
      sanitized_name.gsub!(' ', '_')
      # Remove special characters (except underscores and dots)
      sanitized_name.gsub!(/[^a-z0-9_.]/, '')
      sanitized_name
    end

    def copy_fonts(destination)
      FontCopier.new.copy(destination, @font_files)
    end
end

class IOSFontSwitcher
    def initialize(brand_key, font_files)
      @brand_key = brand_key
      @font_files = font_files
    end

    def switch
      Solara.logger.start_step("Switch iOS fonts")
      destination = FilePath.ios_project_fonts
      copy_fonts(destination)

      font_names = @font_files.map { |file| File.basename(file) }
      info_plist_path = FilePath.info_plist
      manager = IOSPlistManager.new(@project, info_plist_path)
      manager.add_fonts(font_names)

      Solara.logger.end_step("Switch iOS fonts")
    end

    private

    def copy_fonts(destination)
      FontCopier.new.copy(destination, @font_files)
    end
end

  class FontCopier
    def copy(destination, font_files)
      FileUtils.mkdir_p(destination)
      return if font_files.empty?

      FolderCopier.new(FilePath.brand_fonts, destination).copy
    end
  end