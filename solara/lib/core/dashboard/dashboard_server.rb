Dir[File.expand_path('handler/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('platform/android/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('scripts/*.rb', __dir__)].each { |file| require_relative file }

require 'webrick'
require 'json'
require 'cgi'
require 'cgi'

class DashboardServer
    attr_reader :home, :root

    def initialize(home, port, document_root)
        @home = home
        @port = port
        @root = File.expand_path(document_root) || File.expand_path('.')
        @server = nil
        @router = nil
    end

    def start
        create_server
        setup_router
        add_cors_headers
        print_server_info
        open_browser
        start_server
    end

    def shutdown
        Solara.logger.info("Shutting down server...")
        @server.shutdown if @server
    end

    def handle_error(res, error, message, status = 500)
        Solara.logger.failure("#{message}: #{error.message}")
        res.status = status
        res.body = JSON.generate({ success: false, error: "#{message}: #{error.message}" })
        res.content_type = 'application/json'
    end

    private

    def create_server
        logger = WEBrick::Log.new($stderr, Solara.verbose ? WEBrick::Log::DEBUG : WEBrick::Log::INFO)
        @server = WEBrick::HTTPServer.new(
            Port: @port,
            DocumentRoot: @root,
            DirectoryIndex: ['local.html'],
            Logger: logger
        )
    rescue StandardError => e
        Solara.logger.failure("Error creating server: #{e.message}")
        exit(1)
    end

    def setup_router
        @router = Router.new(@server, self)
        register_handlers
        @router.mount_routes
    end

    def register_handlers
        return if @router.nil?

        @router.register_handler(RedirectHandler)
        @router.register_handler(SwitchToBrandHandler)
        @router.register_handler(CurrentBrandHandler)
        @router.register_handler(BrandDetailsHandler)
        @router.register_handler(BrandsHandler)
        @router.register_handler(EditSectionHandler)
        @router.register_handler(OnboardBrandHandler)
        @router.register_handler(OffboardBrandHandler)
        @router.register_handler(DoctorHandler)
        @router.register_handler(BrandAliasesHandler)
        @router.register_handler(BrandIconHandler)
    end

    def add_cors_headers

    end

    def print_server_info
        Solara.logger.info("Server starting on http://localhost:#{@port}")
        Solara.logger.info("http://localhost:#{@port} should open in your browser automatically. If it doesn't, please click it or copy and paste in you browser.")
        Solara.logger.info("Serving files from: #{@root}")
        Solara.logger.info("Press Ctrl+C to stop the server")
    end

    def start_server
        trap 'INT' do
            shutdown
        end

        @server.start
    rescue StandardError => e
        Solara.logger.failure("Error starting server: #{e.message}")
        exit(1)
    end

    def open_browser
        url = "http://localhost:#{@port}"
        Solara.logger.debug("Opening browser at #{url}")
        case RUBY_PLATFORM
        when /darwin/
            system "/usr/bin/open", url
        when /linux/
            # Check if we're in WSL
            if File.exist?('/proc/version') && File.read('/proc/version').include?('Microsoft')
                # Use the Windows start command to open in WSL
                system "cmd.exe", "/c", "start", url
            else
                system "/usr/bin/xdg-open", url
            end
        when /mswin|mingw|cygwin/
            system "start", url
        end
    rescue StandardError => e
        Solara.logger.failure("Error opening browser: #{e.message}")
    end
end

class Router
    def initialize(server, dashboard_server)
        @server = server
        @dashboard_server = dashboard_server
        @handlers = []
    end

    def register_handler(handler_class)
        @handlers << handler_class.new(@server, @dashboard_server)
    end

    def mount_routes
        @handlers.each(&:mount)
    end
end
