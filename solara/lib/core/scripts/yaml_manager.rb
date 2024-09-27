require 'yaml'
require 'psych'

class YamlManager
  def initialize(file_path)
    @file_path = file_path
  end

  def add_font(family, assets)
    yaml_data = load_yaml

    # Ensure the 'flutter' key exists
    yaml_data['flutter'] ||= {}
    yaml_data['flutter']['fonts'] ||= []

    # Check if the font family already exists
    existing_font = yaml_data['flutter']['fonts'].find { |f| f['family'] == family }

    if existing_font
      Solara.logger.debug("YamlManager: Font family '#{family}' already exists.")
      # Update existing font assets
      existing_font['fonts'] = assets
    else
      # Add new font family
      yaml_data['flutter']['fonts'] << { 'family' => family, 'fonts' => assets }
      Solara.logger.debug("YamlManager: Font family '#{family}' has been added.")
    end

    save_yaml(yaml_data)
  end
  
  def add_property(property_name, property_value)
    yaml_data = load_yaml

    if yaml_data.key?(property_name)
      Solara.logger.debug("YamlManager: Property '#{property_name}' already exists in the YAML file.")
    else
      yaml_data[property_name] = property_value
      save_yaml(yaml_data)
      Solara.logger.debug("YamlManager: Property '#{property_name}' has been added to the YAML file.")
    end
  end

  def add_to_array(property_name, value)
    yaml_data = load_yaml

    if yaml_data.key?(property_name)
      if yaml_data[property_name].is_a?(Array)
        yaml_data[property_name] << value
        save_yaml(yaml_data)
        Solara.logger.debug("YamlManager: Value '#{value}' has been added to the array '#{property_name}'.")
      else
        Solara.logger.debug("YamlManager: Property '#{property_name}' exists but is not an array.")
      end
    else
      yaml_data[property_name] = [value]
      save_yaml(yaml_data)
      Solara.logger.debug("YamlManager: New array '#{property_name}' has been created with value '#{value}'.")
    end
  end

  def add_to_nested_array(parent_property, array_property, value)
    yaml_data = load_yaml

    yaml_data[parent_property] ||= {}
    yaml_data[parent_property][array_property] ||= []

    if yaml_data[parent_property][array_property].include?(value)
      Solara.logger.debug("YamlManager: Value '#{value}' already exists in the array '#{array_property}' under '#{parent_property}'.")
    else
      yaml_data[parent_property][array_property] << value
      save_yaml(yaml_data)
      Solara.logger.debug("YamlManager: Value '#{value}' has been added to the array '#{array_property}' under '#{parent_property}'.")
    end
  end

  private

  def load_yaml
    YAML.load_file(@file_path)
  rescue Errno::ENOENT
    Solara.logger.debug("YamlManager: File not found. Creating a new YAML file.")
    {}
  end

  def save_yaml(data)
    File.open(@file_path, 'w') do |file|
      file.write(yaml_dump(data))
    end
  end

  def yaml_dump(data)
    Psych.dump(data, indentation: 2, line_width: -1).gsub(/^---\n/, '')
  end
end