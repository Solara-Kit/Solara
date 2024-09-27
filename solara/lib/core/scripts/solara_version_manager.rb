require 'singleton'

require 'singleton'
require 'json'

class SolaraVersionManager
    include Singleton

    def sversion
        json['solaraVersion']
    end

    def version=(value)
        new_json = json
        new_json['solaraVersion'] = value
        save(new_json)
    end

    def value(key)
        json[key]
    end

    def add(key, value)
        new_json = json
        new_json[key] = value
        save(new_json)
    end

    private

    def json
        path = FilePath.solara_version
        FileManager.create_file_if_not_exist(path)
        JSON.parse(File.read(path))
    rescue JSON::ParserError => e
        {}
    end

    def save(json)
        File.write(FilePath.solara_version, JSON.pretty_generate(json))
    end
end