class BrandAliasesHandler < BaseHandler
    def mount
        @server.mount_proc('/brand/aliases') do |req, res|
            if req.request_method == 'GET'
                begin
                    aliases = get_brand_aliases
                    res.status = 200
                    res.body = JSON.generate({ success: true, aliases: aliases })

                rescue StandardError => e
                    handle_error(res, e, "Error fetching brand aliases")
                end
            else
                method_not_allowed(res)
            end
            res.content_type = 'application/json'
        end
    end

    def get_brand_aliases
        AliasManager.aliases_json
    rescue StandardError => e
        Solara.logger.failure("Error getting brand aliases: #{e.message}")
        raise
    end
end
