class OnboardBrandHandler < BaseHandler
    def mount
        @server.mount_proc('/brand/onboard') do |req, res|
            if req.request_method == 'POST'
                begin
                    data = JSON.parse(req.body)
                    brand_name = data['brand_name']
                    brand_key = data['brand_key']
                    clone_brand_key = data['clone_brand_key']

                    if brand_key
                        result = onboard_brand(brand_name, brand_key, clone_brand_key)
                        res.status = result[:success] ? 200 : 409 # 409 Conflict for existing brand
                        res.body = JSON.generate(result)
                    else
                        res.status = 400
                        res.body = JSON.generate({ success: false, error: 'Missing brand_key parameter' })
                    end
                rescue JSON::ParserError => e
                    handle_error(res, e, "Invalid JSON in request body", 400)
                rescue StandardError => e
                    handle_error(res, e, "Error adding brand")
                end
            else
                method_not_allowed(res)
            end
            res.content_type = 'application/json'
        end
    end

    def onboard_brand(brand_name, brand_key, clone_brand_key = nil)
        if BrandsManager.instance.exists(brand_key)
            return { success: false, message: "Brand with key (#{brand_key}) already added!" }
        end
        SolaraManager.new.onboard(brand_key, brand_name, clone_brand_key: clone_brand_key, open_dashboard: false)
        { success: true, message: "Brand added successfully" }
    end
end
