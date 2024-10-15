require 'json'
require 'fileutils'

class ThemeGenerator
    def initialize(input_path)
        @input_path = input_path
    end

    def generate(language, output_path)
    config_generator = CodeGenerator.new(
        json: JSON.parse(File.read(@input_path)),
        language: language,
        parent_class_name: 'BrandTheme',
        type_overrides: {
          "BrandThemeColorSchemes" => "ThemeColorSchemes",
          "BrandThemeTypography" => "ThemeTypography",
          "BrandThemeSpacing" => "ThemeSpacing",
          "BrandThemeBorderRadius" => "ThemeBorderRadius",
          "BrandThemeElevation" => "ThemeElevation",
          "BrandThemeOpacity" => "ThemeOpacity",
          "BrandThemeAnimation" => "ThemeAnimation",
          "BrandThemeBreakpoints" => "ThemeBreakpoints",
        }
    )
    content = config_generator.generate
    FileManager.create_file_if_not_exist(output_path)
    File.write(output_path, content)
    Solara.logger.debug("Generated theme file: #{output_path}")
    end
end
