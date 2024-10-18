class BaseHandler
    def initialize(server, dashboard_server)
        @server = server
        @dashboard_server = dashboard_server
    end

    def mount
        raise NotImplementedError, "Subclasses must implement the 'mount' method"
    end

    protected

    def handle_error(res, error, message, status = 500)
        Solara.logger.failure("#{message}: #{error.message}")
        res.status = status
        res.body = JSON.generate({ success: false, error: "#{message}: #{error.message}" })
        res.content_type = 'application/json'
        Solara.logger.error(error)
    end

    def method_not_allowed(res)
        res.status = 405
        res.body = JSON.generate({ success: false, error: 'Method Not Allowed' })
        res.content_type = 'application/json'
    end
end