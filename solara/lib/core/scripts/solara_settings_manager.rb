require 'singleton'

require 'singleton'
require 'json'

class SolaraSettingsManager
    include Singleton

    attr_accessor :root, :project_root, :environment

    def initialize
        @environment = SolaraEnvironment::Production
    end

    def platform
        settings['platform']
    end

    def platform=(new_platform)
        json = settings
        json['platform'] = new_platform
        save(json)
    end

    def value(key)
        settings[key]
    end

    def add(key, value)
        json = settings
        json[key] = value
        save(json)
    end

    def is_test_environment
        @environment === 'test'
    end

    private

    def settings
        path = FilePath.solara_settings
        FileManager.create_file_if_not_exist(path)
        JSON.parse(File.read(path))
    rescue JSON::ParserError => e
        {}
    end

    def save(json)
        File.write(FilePath.solara_settings, JSON.pretty_generate(json))
    end
end

module Platform
    Flutter = 'flutter'
    Android = 'android'
    IOS = 'ios'
    Unknown = 'unknown'

    def self.all
        [Flutter, Android, IOS]
    end

    def self.is_ios
        SolaraSettingsManager.instance.platform.downcase == IOS.downcase
    end

    def self.is_android
        SolaraSettingsManager.instance.platform.downcase == Android.downcase
    end

    def self.is_flutter
        SolaraSettingsManager.instance.platform.downcase == Flutter.downcase
    end
end

def init(platform)
    unless Platform.all.include?(platform)
        raise ArgumentError, "Invalid platform. Please use one of: #{Platform.all.join(', ')}"
    end
end

module SolaraEnvironment
    Production = 'production'
    Test = 'test'

    def self.all
        [Production, Test]
    end

    def self.is_production
        SolaraSettingsManager.instance.environment.downcase == Production.downcase
    end

    def self.is_test
        SolaraSettingsManager.instance.environment.downcase == Test.downcase
    end
end