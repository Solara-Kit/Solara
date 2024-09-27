Dir[File.expand_path('scripts/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('platform/android/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('platform/flutter/*.rb', __dir__)].each { |file| require_relative file }

class SolaraConfigurator
    def initialize
    end

    def start
        GitignoreManager.ignore
        AliasManager.new.start
    end

end

