Dir['*.rb'].each { |file| require_relative file }

class EditSectionHandler < BaseHandler
    def mount
        @server.mount_proc('/section/edit') do |req, res|
            if req.request_method == 'POST'
                begin
                    request_payload = JSON.parse(req.body)
                    brand_key = request_payload['brand_key']
                    key = request_payload['key']
                    data = request_payload['data']

                    update_section(key, data, brand_key)
                    set_current_brand_content_changed(brand_key, true)

                    res.status = 200
                    res.body = JSON.generate({ success: true, message: "Configuration for #{key} updated successfully" })
                    res.content_type = 'application/json'
                rescue JSON::ParserError => e
                    handle_error(res, e, "Invalid JSON in request body", 400)
                rescue StandardError => e
                    handle_error(res, e, "Error updating configuration")
                end
            else
                method_not_allowed(res)
            end
        end
    end

    def update_section(key, data, brand_key)
        template = BrandConfigurationsManager.new(brand_key).template_with_key(key)

        path = template[:path]
        
        if File.exist?(path)
            File.write(path, JSON.pretty_generate(data))
            Solara.logger.debug("Updated Config for #{path}: #{data}")
        else
            raise "Config file not found: #{path}"
        end
    rescue StandardError => e
        Solara.logger.failure("Error updating section: #{e.message}")
        raise
    end

    def set_current_brand_content_changed(brand_key, changed)
        BrandsManager.instance.set_current_brand_content_changed(brand_key, changed)
    end

end

