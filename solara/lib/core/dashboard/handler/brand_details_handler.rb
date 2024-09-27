class BrandDetailsHandler < BaseHandler
    def mount
        @server.mount_proc('/brand/details') do |req, res|
            begin
                query = CGI.parse(req.query_string)
                brand_key = query['brand_key']&.first

                response_data = BrandsManager.instance.brand_with_configurations(brand_key)
                res.body = JSON.generate({ success: true, message: "Brand details response", result: response_data })
                res['Content-Type'] = 'application/json'
            rescue StandardError => e
                handle_error(res, e, "Error in brand details handler")
            end
        end
    end

end

