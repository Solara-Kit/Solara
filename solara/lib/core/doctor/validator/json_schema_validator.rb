Dir.glob("#{__dir__}/*.rb").each { |file| require file }
require 'json'
require 'json-schema'

class JsonSchemaValidator < ValidationStrategy
    def initialize(schema_file, json_file)
        @schema_file = schema_file
        @json_file = json_file
    end

    def validate(project_path = nil)

        unless File.exist?(@schema_file)
            raise ValidationError, "Schema file not found: #{@schema_file}"
        end

        begin
            json_content = JSON.parse(File.read(@json_file))
        rescue
            # Ignore as it's not its responsibility
            return
        end
        schema = JSON.parse(File.read(@schema_file))
        errors = JSON::Validator.fully_validate(schema, json_content)

        if errors.empty?
            Solara.logger.passed("Valid according to schema: #{@json_file}")
        else
            raise ValidationError, "#{@json_file}: #{errors.join(', ')}."
        end
    end
end