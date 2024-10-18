Dir.glob("#{__dir__}/../../doctor/validator/*.rb").each { |file| require file }
require 'yaml'
require 'pathname'
require 'json'
require 'json-schema'

class TemplateValidator
    def initialize(project_path, config_file)
        @project_path = Pathname.new(project_path)
        @config = YAML.load_file(config_file)
    end

    def validate
        errors = []
        validate_structure(errors, @project_path, @config['structure'])
        errors
    end

    private

    def validate_structure(errors, current_path, expected_structure)
        expected_structure.each do |name, details|
            path = current_path.join(name)

            if details.is_a?(Hash)
                case details['type']
                when 'directory'
                    validate_directory(errors, path, details)
                when 'file'
                    validate_file(errors, path, details)
                else
                    errors << "Unknown type '#{details['type']}' for #{path}"
                end
            end
        end

        validate_no_extra_files(errors, current_path, expected_structure) if @config['strict']
    end

    def validate_directory(errors, path, details)
        unless path.directory?
            errors << "Missing directory: #{path}"
            return
        end
        validate_structure(errors, path, details['contents']) if details['contents']
    end

    def validate_file(errors, path, details)
        unless path.file?
            errors << "Missing file: #{path}"
            return
        end

        content = File.read(path)

        details['validations']&.each do |validation|
            case validation['type']
            when 'content_includes'
                unless content.include?(validation['value'])
                    errors << "File #{path} does not contain expected content: #{validation['value']}"
                end

            when 'content_matches'
                unless content.match?(Regexp.new(validation['value']))
                    errors << "File #{path} does not match expected pattern: #{validation['value']}"
                end

            when 'file_size'
                size = File.size(path)
                min_size = validation['min_size']
                max_size = validation['max_size']
                if min_size && size < min_size
                    errors << "File #{path} is smaller than expected: #{size} < #{min_size} bytes"
                end
                if max_size && size > max_size
                    errors << "File #{path} is larger than expected: #{size} > #{max_size} bytes"
                end

            when 'valid_json'
                begin
                    JsonFileValidator.new([path]).validate(@project_path)
                rescue StandardError => e
                    errors << e.message
                end

            when 'json_schema'
                begin
                    schema_path = File.join(FilePath.schema, validation['schema_path'])
                    JsonSchemaValidator.new(schema_path, path).validate(@project_path)
                rescue StandardError => e
                    errors << e.message
                end

            else
                errors << "Unknown validation type '#{validation['type']}' for #{path}"
            end
        end
    end

    def validate_no_extra_files(errors, current_path, expected_structure)
        expected_names = expected_structure.keys
        current_path.children.each do |child|
            unless expected_names.include?(child.basename.to_s)
                errors << "Unexpected #{child.directory? ? 'directory' : 'file'}: #{child}"
            end
        end
    end
end