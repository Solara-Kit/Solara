require 'rexml/document'

class StringsXmlManager
  def initialize(file_path)
    @file_path = file_path
    @xml_content = File.read(@file_path, encoding: 'UTF-8')
    @doc = REXML::Document.new(@xml_content)
  end

  def delete_app_name
    app_name_element = @doc.elements['resources/string[@name="app_name"]']
    app_name_element.remove if app_name_element
    save_changes
    Solara.logger.debug("Removed app_name from #{@file_path} to avoid duplication with #{FilePath.artifacts_dir_name}/strings.xml.")
  end

  def update_string_value(string_name, new_value)
    string_element = @doc.elements["resources/string[@name=\"#{string_name}\"]"]
    if string_element
      string_element.text = new_value
      save_changes
      Solara.logger.debug("Updated string '#{string_name}' to '#{new_value}' in #{@file_path}.")
    else
      Solara.logger.warn("String '#{string_name}' not found in #{@file_path}. Update failed.")
    end
  end

  def get_value(string_name)
    @doc.elements["resources/string[@name=\"#{string_name}\"]"].text 
  end

  private

  def save_changes
    File.write(@file_path, @doc.to_s)
  end
end