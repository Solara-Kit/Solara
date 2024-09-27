class BrandsHandler < BaseHandler
    def mount
        @server.mount_proc('/brands/all') do |req, res|
            begin
                brands_list = BrandsManager.instance.brands_list
                json = JSON.generate(brands_list)
                res.body = json
                res['Content-Type'] = 'application/json'
            rescue StandardError => e
                handle_error(res, e, "Error fetching brands list")
            end
        end
    end
end
