require 'singleton'

require 'singleton'
require 'json'

require 'singleton'
require 'json'

class ProjectSettingsManager
    include Singleton

    attr_accessor :root, :project_root

    def value(key, platform)
        settings.dig(platform.to_s, key)
    end

    def add(key, value, platform)
        json = settings
        json[platform.to_s] ||= {}
        json[platform.to_s][key] = value
        save(json)
    end

    private

    def settings
        path = FilePath.project_settings
        FileManager.create_file_if_not_exist(path)
        JSON.parse(File.read(path))
    rescue JSON::ParserError => e
        {}
    end

    def save(json)
        path = FilePath.project_settings
        File.write(path, JSON.pretty_generate(json))
    end
end