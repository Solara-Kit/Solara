# Load required files
Dir[File.expand_path('scripts/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('platform/android/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('platform/ios/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('platform/flutter/*.rb', __dir__)].each { |file| require_relative file }

class BrandSwitcher
  def initialize(brand_key, ignore_health_check: false)
    @brand_key = brand_key
    @ignore_health_check = ignore_health_check
    @platform = SolaraSettingsManager.instance.platform
    @health_checker = HealthChecker.new(@brand_key, @ignore_health_check)
    @artifacts_switcher = ArtifactSwitcher.new(@platform)
  end

  def start
    Solara.logger.header("Switching to #{@brand_key}")

    @health_checker.check_health
    BrandsManager.instance.save_current_brand(@brand_key)
    @artifacts_switcher.switch
    switch
    SolaraConfigurator.new.start

    Solara.logger.success("Switched to #{@brand_key} successfully.")
  end

  private

  def switch
    BrandFontSwitcher.new(@brand_key).switch
    
    ResourceManifestSwitcher.new(@brand_key, ignore_health_check: @ignore_health_check).switch
    JsonManifestSwitcher.new(@brand_key).switch

    case @platform
    when Platform::Flutter
      IOSBrandSwitcher.new(@brand_key).switch
      AndroidBrandSwitcher.new(@brand_key).switch
      FlutterBrandSwitcher.new(@brand_key).switch
    when Platform::IOS
      IOSBrandSwitcher.new(@brand_key).switch
    when Platform::Android
      AndroidBrandSwitcher.new(@brand_key).switch
    else
      raise ArgumentError, "Invalid platform: #{@platform}"
    end

  end

end

class ResourceManifestSwitcher
  def initialize(brand_key, ignore_health_check:)
    @brand_key = brand_key
    @ignore_health_check = ignore_health_check
  end

  def switch
    Solara.logger.start_step("Process resource manifest: #{FilePath.resources_manifest}")
    brand_resource_copier = ResourceManifestProcessor.new(@brand_key, ignore_health_check: @ignore_health_check)
    brand_resource_copier.copy
    Solara.logger.debug("#{@brand_key} resources copied successfully according to the manifest: #{FilePath.resources_manifest}.")
    Solara.logger.end_step("Process resource manifest: #{FilePath.resources_manifest}")
  end

end

class JsonManifestSwitcher
  def initialize(brand_key)
    @brand_key = brand_key
    @manifest_path = FilePath.brand_json_dir(brand_key)
  end

  def switch
    Solara.logger.start_step("Process JSON manifest: #{@manifest_path}")


    case SolaraSettingsManager.instance.platform
    when Platform::Flutter
      process_maifest(Language::Dart, FilePath.flutter_lib_artifacts)
      process_maifest(Language::Dart, FilePath.brand_global_json_dir)
    when Platform::IOS
      process_maifest(Language::Swift, FilePath.ios_project_root_artifacts)
      process_maifest(Language::Swift, FilePath.brand_global_json_dir)
    when Platform::Android
      process_maifest(Language::Kotlin, FilePath.android_project_java_artifacts )
      process_maifest(Language::Kotlin, FilePath.brand_global_json_dir)
    else
      raise ArgumentError, "Invalid platform: #{@platform}"
    end

    Solara.logger.end_step("Process JSON manifest: #{@manifest_path}")
  end

  def process_maifest(language, output_path)
    processor = JsonManifestProcessor.new(
      @manifest_path,
      language,
      output_path
    )
    processor.process
  end
end

class FlutterBrandSwitcher
  def initialize(brand_key)
    @brand_key = brand_key
    @theme_switcher = ThemeSwitcher.new(@brand_key)
    @brand_config_switcher = BrandConfigSwitcher.new(@brand_key)
  end

  def switch
    @theme_switcher.switch(Language::Dart)
    @brand_config_switcher.switch(Language::Dart)
    BrandResourcesSwitcher.new(@brand_key).switch(Platform::Flutter)
  end
end

class AndroidBrandSwitcher
  def initialize(brand_key)
    @brand_key = brand_key
    @theme_switcher = ThemeSwitcher.new(@brand_key)
    @brand_config_switcher = BrandConfigSwitcher.new(@brand_key)
  end

  def switch
    BrandConfigManager.new(@brand_key).generate_android_properties

    config_path = FilePath.android_brand_config(@brand_key)
    config = JSON.parse(File.read(config_path))

    GradleSwitcher.new(@brand_key).switch
    AndroidManifestSwitcher.new.switch(config)
    @theme_switcher.switch(Language::Kotlin)
    @brand_config_switcher.switch(Language::Kotlin)
    BrandResourcesSwitcher.new(@brand_key).switch(Platform::Android)
  end
end

class IOSBrandSwitcher
  def initialize(brand_key)
    @brand_key = brand_key
    @theme_switcher = ThemeSwitcher.new(@brand_key)
    @brand_config_switcher = BrandConfigSwitcher.new(@brand_key)
  end

  def switch
    BrandConfigManager.new(@brand_key).generate_ios_xcconfig
    @theme_switcher.switch(Language::Swift)
    @brand_config_switcher.switch(Language::Swift)
    switch_infoplist
    BrandResourcesSwitcher.new(@brand_key).switch(Platform::IOS)
    switch_xcode_project
  end

  private

  def switch_infoplist
    Solara.logger.start_step("Switch Info.plist")
    project_path = FilePath.xcode_project
    InfoPlistSwitcher.new(project_path, @brand_key).switch
    Solara.logger.end_step("Switch Info.plist")
  end

  def switch_xcode_project
    Solara.logger.start_step("Switch Xcode project")
    project_path = FilePath.xcode_project
    XcodeProjectSwitcher.new(project_path, @brand_key).switch
    Solara.logger.end_step("Switch Xcode project")
  end
end

class HealthChecker
  def initialize(brand_key, ignore_health_check)
    @brand_key = brand_key
    @ignore_health_check = ignore_health_check
  end

  def check_health
    health_errors = SolaraManager.new.doctor([@brand_key]).select { |issue| issue.type == Issue::ERROR }
    return if health_errors.empty?

    unless @ignore_health_check
      errors_with_index = health_errors.each_with_index.map { |error, index| "#{index + 1}: #{error}" }
      raise Issue.error("Health check completed with errors: \n\n#{errors_with_index.join("\n")}.")
    end
  end
end

class ArtifactSwitcher
  def initialize(platform)
    @platform = platform
  end

  def switch
    Solara.logger.start_step("Switch artifacts directories")
    directories = directories_for_platform
    DirectoryCreator.create_directories(directories, delete_if_exists: true)
    Solara.logger.end_step("Switch artifacts directories")
  end

  private

  def directories_for_platform
    case @platform
    when Platform::Flutter
      FlutterArtifactSwitcher.new.directories +
      IOSArtifactSwitcher.new.directories +
      AndroidArtifactSwitcher.new.directories
    when Platform::IOS
      IOSArtifactSwitcher.new.directories
    when Platform::Android
      AndroidArtifactSwitcher.new.directories
    else
      raise ArgumentError, "Invalid platform: #{@platform}"
    end
  end
end

class FlutterArtifactSwitcher
  def directories
    [
      FilePath.flutter_lib_artifacts,
      FilePath.flutter_assets_artifacts,
      FilePath.flutter_project_fonts,
    ]
  end
end

class IOSArtifactSwitcher
  def directories
    [
      FilePath.ios_project_root_artifacts,
      FilePath.ios_project_assets_artifacts,
    ]
  end
end

class AndroidArtifactSwitcher
  def directories
    [
      FilePath.android_project_root_artifacts,
      FilePath.android_project_main_artifacts,
      FilePath.android_project_java_artifacts,
      FilePath.android_project_assets_artifacts
    ]
  end
end

class ThemeSwitcher
  def initialize(brand_key)
    @brand_key = brand_key
  end

  def switch(language)
        case language
    when Language::Dart
      generate_dart
    when Language::Kotlin
      generate_kotlin
    when Language::Swift
      generate_swift
    else
      raise ArgumentError, "Invalid language: #{language}"
    end
  end

  def generate_dart
    generate_theme('brand_theme.dart', Language::Dart, Platform::Flutter)
  end

  def generate_kotlin
    generate_theme('BrandTheme.kt', Language::Kotlin, Platform::Android)
  end

  def generate_swift
    generate_theme('BrandTheme.swift', Language::Swift, Platform::IOS)
  end

  private

  def generate_theme(name, language, platform)
    Solara.logger.start_step("Generate #{name} for #{platform}")

    theme_manager = ThemeGenerator.new(FilePath.brand_theme(@brand_key))
    theme_manager.generate(language, FilePath.generated_config(name, platform))

    Solara.logger.end_step("Generate #{name} for #{platform}")
  end
end

class BrandConfigSwitcher
  def initialize(brand_key)
    @brand_key = brand_key
  end

  def switch(language)
        case language
    when Language::Dart
      generate_dart
    when Language::Kotlin
      generate_kotlin
    when Language::Swift
      generate_swift
    else
      raise ArgumentError, "Invalid language: #{language}"
    end
  end

  def generate_dart
    generate_brand_config('brand_config.dart', Language::Dart, Platform::Flutter)
  end

  def generate_kotlin
    generate_brand_config('BrandConfig.kt', Language::Kotlin, Platform::Android)
  end

  def generate_swift
    generate_brand_config('BrandConfig.swift', Language::Swift, Platform::IOS)
  end

  private

  def generate_brand_config(name, language, platform)
    BrandConfigManager.new(@brand_key).generate_brand_config(name, language, platform)
  end
end