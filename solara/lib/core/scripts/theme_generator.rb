require 'json'
require 'fileutils'

class ThemeGeneratorManager
    def initialize(input_path)
        @input_path = input_path
    end

    def generate(language, output_path)
        case language.downcase
        when 'kotlin'
            generator = KotlinThemeGenerator.new(@input_path, output_path)
        when 'swift'
            generator = SwiftThemeGenerator.new(@input_path, output_path)
        when 'dart'
            generator = DartThemeGenerator.new(@input_path, output_path)
        else
            Solara.logger.fatal("Unsupported language: #{language}")
            return
        end

        generator.generate
    end
end

class ThemeGenerator
    def initialize(input_path, output_path)
        @theme = JSON.parse(File.read(input_path))
        @output_path = output_path
    end

    def write_to_file(code)
        FileUtils.mkdir_p(File.dirname(@output_path))
        File.write(@output_path, code)
        Solara.logger.debug("Generated theme file: #{@output_path}")
    end
end

class KotlinThemeGenerator < ThemeGenerator
    def generate
        code = "import android.graphics.Color\n\n"
        code += "object BrandTheme {\n"
        code += generate_colors
        code += generate_typography
        code += generate_spacing
        code += generate_border_radius
        code += generate_elevation
        code += "}"
        write_to_file(code)
    end

    private

    def generate_colors
        code = "    object Colors {\n"
        @theme['colors'].each do |name, value|
            code += "        val #{name} = Color.parseColor(\"#{value}\")\n"
        end
        code + "    }\n\n"
    end

    def generate_typography
        code = "    object Typography {\n"
        code += "        object FontFamily {\n"
        @theme['typography']['fontFamily'].each do |name, value|
            code += "            val #{name} = \"#{value}\"\n"
        end
        code += "        }\n\n"
        code += "        object FontSize {\n"
        @theme['typography']['fontSize'].each do |name, value|
            code += "            val #{name} = #{value}\n"
        end
        code += "        }\n"
        code + "    }\n\n"
    end

    def generate_spacing
        code = "    object Spacing {\n"
        @theme['spacing'].each do |name, value|
            code += "        val #{name} = #{value}\n"
        end
        code + "    }\n\n"
    end

    def generate_border_radius
        code = "    object BorderRadius {\n"
        @theme['borderRadius'].each do |name, value|
            code += "        val #{name} = #{value}\n"
        end
        code + "    }\n\n"
    end

    def generate_elevation
        code = "    object Elevation {\n"
        @theme['elevation'].each do |name, value|
            code += "        val #{name} = #{value}\n"
        end
        code + "    }\n"
    end
end

class SwiftThemeGenerator < ThemeGenerator
    def generate
        code = "import UIKit\n\n"
        code += "struct BrandTheme {\n"
        code += generate_colors
        code += generate_typography
        code += generate_spacing
        code += generate_border_radius
        code += generate_elevation
        code += "}\n\n"
        code += generate_colors_hex_extension
        write_to_file(code)
    end

    private

    def generate_colors
        code = "    struct Colors {\n"
        @theme['colors'].each do |name, value|
            code += "        static let #{name} = UIColor(hex: \"#{value}\")\n"
        end
        code + "    }\n\n"
    end

    def generate_colors_hex_extension
        <<-SWIFT
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 0)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
        SWIFT
    end

    def generate_typography
        code = "    struct Typography {\n"
        code += "        struct FontFamily {\n"
        @theme['typography']['fontFamily'].each do |name, value|
            code += "            static let #{name} = \"#{value}\"\n"
        end
        code += "        }\n\n"
        code += "        struct FontSize {\n"
        @theme['typography']['fontSize'].each do |name, value|
            code += "            static let #{name}: CGFloat = #{value}\n"
        end
        code += "        }\n"
        code + "    }\n\n"
    end

    def generate_spacing
        code = "    struct Spacing {\n"
        @theme['spacing'].each do |name, value|
            code += "        static let #{name}: CGFloat = #{value}\n"
        end
        code + "    }\n\n"
    end

    def generate_border_radius
        code = "    struct BorderRadius {\n"
        @theme['borderRadius'].each do |name, value|
            code += "        static let #{name}: CGFloat = #{value}\n"
        end
        code + "    }\n\n"
    end

    def generate_elevation
        code = "    struct Elevation {\n"
        @theme['elevation'].each do |name, value|
            code += "        static let #{name}: CGFloat = #{value}\n"
        end
        code + "    }\n"
    end
end

class DartThemeGenerator < ThemeGenerator
    def generate
        code = "import 'package:flutter/material.dart';\n\n"
        code += generate_colors
        code += generate_typography
        code += generate_spacing
        code += generate_border_radius
        code += generate_elevation
        write_to_file(code)
    end

    private

    def generate_colors
        code = "  class BrandColors {\n"
        @theme['colors'].each do |name, value|
            code += "    static const Color #{name} = Color(0xFF#{value[1..-1]});\n"
        end
        code + "  }\n\n"
    end

    def generate_typography
        code = "  class FontFamily {\n"
        @theme['typography']['fontFamily'].each do |name, value|
            code += "    static const String #{name} = '#{value}';\n"
        end
        code += "  }\n\n"
        code += "  class FontSize {\n"
        @theme['typography']['fontSize'].each do |name, value|
            code += "    static const double #{name} = #{value};\n"
        end
        code + "  }\n\n"
    end

    def generate_spacing
        code = "  class Spacing {\n"
        @theme['spacing'].each do |name, value|
            code += "    static const double #{name} = #{value};\n"
        end
        code + "  }\n\n"
    end

    def generate_border_radius
        code = "  class BorderRadius {\n"
        @theme['borderRadius'].each do |name, value|
            code += "    static const double #{name} = #{value};\n"
        end
        code += "  }\n\n"
    end

    def generate_elevation
        code = "  class Elevation {\n"
        @theme['elevation'].each do |name, value|
            code += "    static const double #{name} = #{value};\n"
        end
        code + "  }\n"
    end
end