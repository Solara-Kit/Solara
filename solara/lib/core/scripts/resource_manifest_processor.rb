require 'json'
require 'fileutils'

class ResourceManifestProcessor
  def initialize(brand_key)
    @brand_key = brand_key
    @manifest_file = FilePath.resources_manifest
    @config = load_manifest_file
  end

  def copy
    @base_source_path = FilePath.brands
    @base_destination_path = FilePath.project_root
    @config['files'].each do |item|
      process_file_item(item)
    end
  end

  private

  def clean(item, src, dst)
    paths = destinations(item, src, dst)
    paths.each do |path|
      File.delete(path) if File.exist?(path)
    end
  end

  def process_file_item(item)
    src = resolve_source_path(@brand_key, item['source'], @base_source_path)
    dst = File.join(@base_destination_path, item['destination'])

    clean(item, src, dst)

    return skip_empty_paths(item) if empty_paths?(item)

    check_mandatory_file(item, src, dst)

    if File.exist?(src)
      copy_file(src, dst)
      git_ignore(destinations(item, src, dst))
    else
      log_file_not_found(item)
    end
  end

  def destinations(item, src, dst, visited = {})
    return [] if visited[src]

    visited[src] = true  # Mark the current source as visited

    if File.file?(src)
      if File.directory?(dst)
        return [File.join(dst, File.basename(src))]
      else
        return [dst]
      end
    elsif File.directory?(src)
      return destinations_of_directory_contents(src, dst)
    end

    if !item['mandatory'] && !File.file?(src)
      return get_optional_resource_destination(item, dst, visited)
    end

    []
  end

  def get_optional_resource_destination(item, dst, visited)
    return [] if item['mandatory']
    keys = BrandsManager.instance.brands_list.map { |brand| brand['key'] }
    keys.each do |key|
      src = resolve_source_path(key, item['source'], @base_source_path)
      result = destinations(item, src, dst, visited)
      return result unless result.empty?
    end
    []
  end

  def destinations_of_directory_contents(src_dir, dst_dir)
    items = []
    Dir.foreach(src_dir) do |file|
      next if file == '.' || file == '..'
      full_dst_path = File.join(dst_dir, file)
      items << full_dst_path
    end
    items
  end

  def git_ignore(files)
    files.each do |file|
      GitignoreManager.new(FilePath.project_root).add_items([file])
    end
  end

  def resolve_source_path(brand_key, source, base_source_path)
    source.gsub(/\{.*?\}/, brand_key).prepend(base_source_path + '/')
  end

  def empty_paths?(item)
    item['source'].empty? || item['destination'].empty?
  end

  def skip_empty_paths(item)
    Solara.logger.debug("Skipped (empty source or destination) for #{@brand_key}: #{item['source']} -> #{item['destination']}")
  end

  def check_mandatory_file(item, src, dst)
    if item['mandatory'] && !File.exist?(src)
      Solara.logger.fatal("Mandatory resource file/folder not found for #{@brand_key}: #{src}. Please add the resource or mark it as not mandatory in #{FilePath.resources_manifest}.")
      exit 1
    end

  end

  def copy_file(src, dst)
    if File.directory?(src)
      FileUtils.mkdir_p(dst)
      FileUtils.cp_r(File.join(src, '.'), dst)
    else
      FileUtils.mkdir_p(File.dirname(dst))
      FileUtils.cp(src, dst)
    end
    Solara.logger.debug("Copied resource for #{@brand_key}: #{File.basename(src)} to #{File.basename(dst)}")
  end

  def log_file_not_found(item)
    Solara.logger.debug("Skipped resource (not found) for #{@brand_key}: #{item['source']}")
  end

  def load_manifest_file
    validate_manifest_file_existence
    parse_manifest_file
  end

  def validate_manifest_file_existence
    unless File.exist?(@manifest_file)
      Solara.logger.fatal("Brand switch copy manifest not found for #{@brand_key}: #{@manifest_file}")
      exit 1
    end
  end

  def parse_manifest_file
    begin
      JSON.parse(File.read(@manifest_file))
    rescue JSON::ParserError => e
      Solara.logger.fatal("Invalid brand switch copy manifest for #{@brand_key}: #{e.message}")
      exit 1
    end
  end

end