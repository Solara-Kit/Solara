require 'fileutils'
require 'json'

class ProjectTemplateGenerator
  def initialize(template_dir, target_dir, config_file)
    @template_dir = template_dir
    @target_dir = target_dir
    @config_file = config_file
    @config = read_config
    @file_mappings = build_file_mappings
  end

  def create_project
    @config["files"].each do |file|
      next unless evaluate_condition(file["condition"], @config["variables"])
      source_path = File.join(@template_dir, file["source"])
      target_path = File.join(@target_dir, file["target"])

      if file["source"].nil? || file["source"].empty? || !File.exist?(source_path)
        # Create the target directory if no source path is provided
        FileUtils.mkdir_p(target_path)
      else
        copy_content = file.fetch("copy_content", true)
        copy_item(source_path, target_path, copy_content, file)
        replace_variables(target_path, @config["variables"]) if copy_content
      end
    end
  end

  def sync_with_template
    @config["files"].each do |file|
      next unless evaluate_condition(file["condition"], @config["variables"])
      next if file["source"].nil? || file["source"].empty?

      source_path = File.join(@template_dir, file["source"])
      target_path = File.join(@target_dir, file["target"])

      next unless File.exist?(source_path)

      if File.directory?(source_path)
        FileUtils.mkdir_p(target_path) unless Dir.exist?(target_path)
        sync_directory(source_path, target_path, file)
      elsif !File.exist?(target_path) && should_copy_path?(source_path)
        FileUtils.mkdir_p(File.dirname(target_path))
        FileUtils.cp(source_path, target_path)
        copy_content = file.fetch("copy_content", true)
        replace_variables(target_path, @config["variables"]) if copy_content
      end
    end
  end

  private

#   This method:
#   - Creates a hash of source paths to their targets
#   - Removes leading slashes for consistency
#   - Handles directories differently from files
#   - For directories: stores true to indicate it's a directory that should be copied
#   For files: stores the specific target path
  def build_file_mappings
    mappings = {}
    @config["files"].each do |file|
      source_path = file["source"].sub(/^\//, '') # Removes leading slashes for consistency
      if File.directory?(File.join(@template_dir, source_path))
        mappings[source_path] = true  # Directories are marked as true
      else
        mappings[source_path] = file["target"]  # Files store their target path
      end
    end
    mappings
  end

#   This method:
#   - Converts the full path to a relative path
#   - Checks if the path matches any configured source
#   - For directories (ending with '/'): checks if the path is within that directory
#   - For files: checks for exact matches
#   - Returns false if no match is found
  def should_copy_path?(path)
    relative_path = path.sub(@template_dir, '').sub(/^\//, '')

    @file_mappings.each do |source, target|
      if source.end_with?('/')
        return true if relative_path.start_with?(source)
      else
        return true if relative_path == source
      end
    end

    false
  end

  def get_target_path(source_path)
    relative_path = source_path.sub(@template_dir, '').sub(/^\//, '')
    @config["files"].each do |file|
      if file["source"] == relative_path
        return File.join(@target_dir, file["target"])
      end
    end
    nil
  end

  def sync_directory(source_dir, target_dir, config_entry)
    return unless File.directory?(source_dir)

    Dir.foreach(source_dir) do |item|
      next if item == '.' || item == '..'

      source_path = File.join(source_dir, item)

      if specific_target = get_target_path(source_path)
        target_path = specific_target
      else
        target_path = File.join(target_dir, item)
      end

      next unless should_copy_path?(source_path)

      if File.directory?(source_path)
        FileUtils.mkdir_p(target_path) unless Dir.exist?(target_path)
        sync_directory(source_path, target_path, config_entry)
      elsif !File.exist?(target_path)
        FileUtils.mkdir_p(File.dirname(target_path))
        FileUtils.cp(source_path, target_path)
      end
    end
  end

  def read_config
    JSON.parse(File.read(@config_file))
  end

  def evaluate_condition(condition, variables)
    true
  end

  def copy_item(source, target, copy_content, config_entry)
    if File.directory?(source)
      FileUtils.mkdir_p(target)
      Dir.foreach(source) do |item|
        next if item == '.' || item == '..'
        source_path = File.join(source, item)

        if specific_target = get_target_path(source_path)
          target_path = specific_target
        else
          target_path = File.join(target, item)
        end

        next unless should_copy_path?(source_path)
        copy_item(source_path, target_path, copy_content, config_entry)
      end
    else
      FileUtils.mkdir_p(File.dirname(target))
      return if File.exist?(target)

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