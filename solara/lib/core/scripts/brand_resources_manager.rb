require 'fileutils'

  class BrandResourcesSwitcher

    def initialize(brand_key)
      @brand_key = brand_key
    end

    def switch(platform)
      case platform
      when Platform::Flutter
        FlutterResourcesSwitcher.new(@brand_key).switch
        AndroidResourcesSwitcher.new(@brand_key).switch
        IOSResourcesSwitcher.new(@brand_key).switch
      when Platform::Android
        AndroidResourcesSwitcher.new(@brand_key).switch
      when Platform::IOS
        IOSResourcesSwitcher.new(@brand_key).switch
      else
          raise ArgumentError, "Invalid platform: #{platform}"
      end
    end
  end

  class IOSResourcesSwitcher

    def initialize(brand_key)
      @brand_key = brand_key
    end

    def switch
        Solara.logger.log_step("Switch iOS resources") do
          add_raw_assets_to_asset_catalog

          copy_directories_not_files(FilePath.ios_brand_xcassets(@brand_key), FilePath.ios_project_assets_artifacts)

          switch_brand_name

          copy_solara_assets

          remove_original_app_icon
        end
    end

    private

    def switch_brand_name
      brand_config_path = FilePath.brand_config(@brand_key)
      brand_config = JSON.parse(File.read(brand_config_path))
      brand_name = brand_config['brandName']

      manager = InfoPListStringCatalogManager.new(FilePath.project_infoplist_string_catalog)
      source_language = manager.source_language
      data = {
        "CFBundleDisplayName" => {
          source_language => brand_name
        },
        "CFBundleName" => {
          source_language => brand_name
        }
      }
      manager.update(data, can_remove_extra_values: false)

      Solara.logger.debug("Updated app anme in #{FilePath.project_infoplist_string_catalog} from #{brand_config_path}.")
    end


    def copy_solara_assets
      source = FilePath.ios_brand_assets(@brand_key)
      destination = FilePath.ios_project_artifacts_assets

      return unless File.exist?(source)

      FolderCopier.new(source, destination).copy
    end

    def add_raw_assets_to_asset_catalog
      source = FilePath.ios_brand_xcassets(@brand_key)
      destination = FilePath.ios_project_assets_artifacts
      asset_manager = XcodeAssetManager.new(destination)
      asset_manager.add(source)
    end

    def copy_directories_not_files(source, destination)
      Dir.glob("#{source}/*").each do |item|
        if File.directory?(item)
          destination_path = File.join(destination, File.basename(item))
          FolderCopier.new(item, destination_path).copy
        end
      end
    end

    def remove_original_app_icon
      FileManager.delete_if_exists(FilePath.ios_project_original_app_icon)
    end
  end

  class AndroidResourcesSwitcher

    def initialize(brand_key)
      @brand_key = brand_key
    end

    def switch
      Solara.logger.log_step("Switch Android resources") do
        FileManager.new.copy_files_recursively(
          FilePath.android_brand_res(@brand_key),
          FilePath.android_project_main_artifacts
        )

        AndroidStringsSwitcher.new(@brand_key).switch

        assets_artifacts = FilePath.android_project_assets_artifacts

        FileManager.new.copy_files_recursively(
          FilePath.android_brand_assets(@brand_key),
          assets_artifacts
        )

        FileManager.new.delete_folders_by_prefix(FilePath.android_project_res, 'mipmap')
      end
    end

  end

  class FlutterResourcesSwitcher

      def initialize(brand_key)
        @brand_key = brand_key
      end

    def switch
      return unless Platform.is_flutter

      Solara.logger.log_step("Switch Flutter resources") do
        YamlManager.new(FilePath.pub_spec_yaml).add_to_nested_array(
          'flutter',
          'assets',
          "assets/#{FilePath.artifacts_dir_name}/"
        )

        destination = FilePath.flutter_assets_artifacts

        FileManager.new.copy_files_recursively(
          FilePath.brand_flutter_assets(@brand_key),
          destination
        )
      end
    end
  end