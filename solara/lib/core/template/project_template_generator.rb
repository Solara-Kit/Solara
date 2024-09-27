require 'fileutils'
require 'json'

class ProjectTemplateGenerator
  def initialize(template_dir, target_dir, config_file)
    @template_dir = template_dir
    @target_dir = target_dir
    @config_file = config_file
    @config = read_config
  end

  def create_project
    @config["files"].each do |file|
      if evaluate_condition(file["condition"], @config["variables"])
        source_path = File.join(@template_dir, file["source"])
        target_path = File.join(@target_dir, file["target"])

        if file["source"].nil? || file["source"].empty? || !File.exist?(source_path)
          # Create the target directory if no source path is provided
          FileUtils.mkdir_p(target_path)
        else
          copy_content = file.fetch("copy_content", true)
          copy_item(source_path, target_path, copy_content)
          replace_variables(target_path, @config["variables"]) if copy_content
        end
      end
    end
  end

  private

  def read_config
    JSON.parse(File.read(@config_file))
  end

  def evaluate_condition(condition, variables)
    true
  end

  def copy_item(source, target, copy_content)
    if File.directory?(source)
      FileUtils.mkdir_p(target)
      Dir.foreach(source) do |item|
        next if item == '.' || item == '..'
        copy_item(File.join(source, item), File.join(target, item), copy_content)
      end
    else
      FileUtils.mkdir_p(File.dirname(target))
      if File.exist?(source) && copy_content
        FileUtils.cp(source, target)
      else
        FileUtils.touch(target)
      end
    end
  end

  def replace_variables(file_path, variables)
    return unless File.exist?(file_path) && File.file?(file_path)

    content = File.read(file_path)
    
    variables.each do |key, value|
      content.gsub!(/\{\{#{key}\}\}/, value.to_s)
    end
    
    File.write(file_path, content)
  end
end