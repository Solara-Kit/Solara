class PlistFontManager
    def initialize(plist_path)
      @plist_path = plist_path
      load_plist
    end

    def load_plist
      @plist = Plist.parse_xml(@plist_path)
      @plist['UIAppFonts'] ||= []
    end

    def add_fonts(font_names)
        font_names.each do |font_name|
          add_font(font_name)
        end
    end

    def add_font(font_name)
      unless @plist['UIAppFonts'].include?(font_name)
        @plist['UIAppFonts'] << font_name
        save_plist
        Solara.logger.debug("#{font_name} added to UIAppFonts.")
      else
        Solara.logger.debug("#{font_name} already exists in UIAppFonts.")
      end
    end

    def save_plist
      File.open(@plist_path, 'w') do |file|
        file.write(Plist::Emit.dump(@plist))
      end
    end
  end