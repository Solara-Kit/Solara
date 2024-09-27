require 'singleton'
require 'json'
require 'rubygems'

class BrandsManager
    include Singleton

    # Class method to access the singleton instance
    def self.instance
        @instance ||= new
    end
    
    def initialize
        brands_list_path = FilePath.brands_list
        @brands_list = JSON.parse(File.read(brands_list_path))
    end

    def first_brand_key
        brands_list.first["key"]
    rescue
        nil
    end

    def brand_with_configurations(brand_key)
        configurations = BrandConfigurationsManager.new(brand_key).create
        {
            solaraVersion: Gem.loaded_specs['solara'].version.to_s,
            brand: brand_data(brand_key),
            configurations: configurations
        }
    end

    def brand_data(brand_key)
        brands_list.find { |brand| brand["key"] == brand_key }
    end

    def brands_list
        @brands_list["brands"]
    end

    def exists(brand_key)
        !brand_data(brand_key).nil? && File.exist?(FilePath.brand(brand_key))
    end

    def add_brand(brand_name, brand_key)
        brand = { 'key' => brand_key, 'name' => brand_name }
        existing_brand = brand_data(brand_key)
        if existing_brand
            update_brand(brands_list.index(existing_brand), brand)
            Solara.logger.debug("#{brand_name} Brand updated in the brands list.")
        else
            brands_list.push(brand)
            save_brands_list
            Solara.logger.debug("#{brand_name} added to the brands list.")
        end
    end

    def has_current_brand
       value = File.exist?(FilePath.current_brand)
       Solara.logger.debug("No current brand!") unless value
       value
    end

    def current_brand
        unless has_current_brand
            return nil
        end
        JSON.parse(File.read(FilePath.current_brand))
    end

    def set_current_brand_content_changed(brand_key, changed)
        unless has_current_brand
            return nil
        end
        unless is_current_brand(brand_key)
            return false
        end
        Solara.logger.debug("")
        brand = current_brand
        brand['content_changed'] = changed
        save_current_brand_data(brand)
        Solara.logger.debug("#{brand_key} changed saved to current_brand.json.")
    end

    def is_current_brand(brand_key)
        unless has_current_brand
            return false
        end
        current_brand['key'] == brand_key
    end

    def save_current_brand(brand_key)
        brand = brand_data(brand_key)
        save_current_brand_data(brand)
        Solara.logger.debug("#{brand_key} saved as current brand.")
    end

    def save_current_brand_data(brand_data)
        path = FilePath.current_brand

        # Create the file if it doesn't exist
        FileUtils.touch(path) unless File.exist?(path)

        File.open(path, 'w') do |file|
            file.write(JSON.pretty_generate(brand_data))
        end

    end

    def update_brand(index, new_brand)
        brands_list[index] = new_brand
        save_brands_list
        Solara.logger.debug("Brand updated.")
    end

    def remove_brand(index)
        brands_list.delete_at(index)
        save_brands_list
        Solara.logger.debug("Brand removed.")
    end

    def offboard(brand_key)
        index = brands_list.find_index { |brand| brand["key"] == brand_key }
        if index
            brand_dir = FilePath.brand(brand_key)
            remove_brand(index)
            FileManager.delete_if_exists(brand_dir)
            save_brands_list
            Solara.logger.debug("Brand removed.")
        else
            Solara.logger.debug("Brand not found (#{brand_key}).")
        end
    end

    private

    def save_brands_list
        brands_list_path = FilePath.brands_list
        File.open(brands_list_path, 'w') do |file|
            file.write(JSON.pretty_generate(@brands_list))
        end
    end

    private_class_method :new
end