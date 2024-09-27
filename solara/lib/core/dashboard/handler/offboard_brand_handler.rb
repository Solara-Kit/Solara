class OffboardBrandHandler < BaseHandler
    def mount
        @server.mount_proc('/brand/offboard') do |req, res|
            if req.request_method == 'GET'
                begin
                    query = CGI.parse(req.query_string)
                    brand_key = query['brand_key']&.first

                    if brand_key
                        offboard(brand_key)
                        res.status = 200
                        res.body = JSON.generate({ success: true, message: "Deleted brand: #{brand_key}" })
                    else
                        res.status = 400
                        res.body = JSON.generate({ success: false, error: 'Missing brand_key parameter' })
                    end
                rescue StandardError => e
                    handle_error(res, e, "Error deleting brand")
                end
            else
                method_not_allowed(res)
            end
            res.content_type = 'application/json'
        end
    end

    def offboard(brand_key)
        SolaraManager.new.offboard(brand_key, confirm: false)
    rescue StandardError => e
        Solara.logger.failure("Error deleting brand: #{e.message}")
        raise
    end

end