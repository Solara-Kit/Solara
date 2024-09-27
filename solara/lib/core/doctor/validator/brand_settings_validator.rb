class BrandSettingsValidator
    def validate_properties(property_names, file_path_method, issue_type:)
        property_names.flat_map { |property_name|
            validate_single_property(property_name, file_path_method, issue_type: issue_type)
        }
    end

    def validate_single_property(property_name, file_path_method, issue_type:)
        validation_result = gather_property_data(property_name, file_path_method, issue_type: issue_type)
        validation_result[:issues]
    end

    def validate_property_duplicates(property_name, file_path_method, issue_type:)
        validation_result = gather_property_data(property_name, file_path_method, issue_type: issue_type)
        property_value_to_brands_map = validation_result[:property_value_to_brands_map]
        identify_duplicate_properties(property_value_to_brands_map, issue_type: issue_type)
    end

    private

    def gather_property_data(property_name, file_path_method, issue_type:)
        brands = BrandsManager.instance.brands_list
        issues = []
        property_value_to_brands_map = {}

        brands.each do |brand|
            brand_key = brand['key']

             unless File.exist?(FilePath.brand(brand_key))
                 Solara.logger.fatal("#{brand_key} not found in #{FilePath.brands}")
                 next
             end

            property_value = fetch_json_property(property_name, FilePath.public_send(file_path_method, brand_key))

            if property_value.to_s.strip.empty?
                issues << Issue.new(issue_type, "#{brand_key}: (#{property_name}) is empty.")
                next
            end

            map_key = "#{property_value} for #{property_name}"
            (property_value_to_brands_map[map_key] ||= []) << brand_key
        end

        { issues: issues, property_value_to_brands_map: property_value_to_brands_map }
    end

    def fetch_json_property(property, file_path)
        JSON.parse(File.read(file_path))[property]
    rescue JSON::ParserError, Errno::ENOENT => e
        raise Issue.error("Error reading JSON file at #{file_path}: #{e.message}")
    end

    def identify_duplicate_properties(property_value_to_brands_map, issue_type:)
        property_value_to_brands_map.each_with_object([]) do |(property_value, brand_keys), issues|
            if brand_keys.size > 1
                issues << Issue.new(issue_type, "[#{brand_keys.join(', ')}]: Duplicate value #{property_value}")
            end
        end
    end
end