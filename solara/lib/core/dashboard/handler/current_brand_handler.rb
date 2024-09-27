class CurrentBrandHandler < BaseHandler
    def mount
        @server.mount_proc('/brand/current') do |req, res|
            begin
                current_brand = BrandsManager.instance.current_brand
                if current_brand
                    res.status = 200
                    res.body = JSON.generate(current_brand)
                else
                    res.status = 204 # No Content
                end
                res.content_type = 'application/json'
            rescue StandardError => e
                handle_error(res, e, "Error fetching current brand")
            end
        end
    end
end
