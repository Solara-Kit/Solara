Dir.glob("#{__dir__}/*.rb").each { |file| require file }

require 'json'

class JsonFileValidator < ValidationStrategy
    def initialize(json_files)
        @json_files = json_files
    end

    def validate(project_path = nil)
        @json_files.each do |json_file|
            begin
                path = json_file
                JSON.parse(File.read(path))
                Solara.logger.passed("Valid JSON: #{path}")
            rescue JSON::ParserError => e
                raise ValidationError, "Not valid JSON: #{path}. Error: #{e.message}"
            end
        end
    end
end