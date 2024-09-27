class BrandIconHandler < BaseHandler
    def mount
        @server.mount_proc("/brand/icon") do |req, res|
            begin
                brand_key = req.query['brand_key']
                filepath = FilePath.launcher_icon(brand_key)
                if File.exist?(filepath)
                    res.body = File.binread(filepath) # Use binread for binary files
                    res['Content-Type'] = 'image/png' # Adjust as necessary
                else
                    res.status = 404
                    res.body = JSON.generate({ error: "Icon not found for brand: #{brand_key}" })
                    res['Content-Type'] = 'application/json'
                end
            rescue StandardError => e
                handle_error(res, e, "Error fetching brand icon")
            end
        end
    end
end