class SwitchToBrandHandler < BaseHandler
    def mount
        @server.mount_proc('/switch') do |req, res|
            if req.request_method == 'POST'
                begin
                    request_payload = JSON.parse(req.body)
                    brand_key = request_payload['brand_key']

                    result = SolaraManager.new.switch(brand_key)
                    Solara.logger.debug(result)

                    res.status = 200
                    res.body = JSON.generate({ success: true, message: "Switched to brand: #{brand_key}", result: result })
                    res.content_type = 'application/json'
                rescue JSON::ParserError => e
                    handle_error(res, e, "Invalid JSON in request body", 400)
                rescue StandardError => e
                    handle_error(res, e, "Error switching to brand")
                end
            else
                method_not_allowed(res)
            end
        end
    end
end