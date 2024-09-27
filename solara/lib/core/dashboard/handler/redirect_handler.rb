class RedirectHandler < BaseHandler
    def mount
        @server.mount_proc('/redirect') do |req, res|
            begin
                res.content_type = 'application/json'
                res.body = JSON.generate({ redirect_url: @dashboard_server.home })
            rescue StandardError => e
                handle_error(res, e, "Error in redirect handler")
            end
        end
    end
end