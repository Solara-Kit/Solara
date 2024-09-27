class DashboardManager

    def start(brand_key = nil, port = 8000)
        return if SolaraEnvironment.is_test
        
        Solara.logger.header("Solara Dashboard #{brand_key.nil? || brand_key.empty? ? "" : "for #{brand_key}"}")
        if brand_key.nil? || brand_key.empty?
            open("brands/brands.html?source=local", port)
            Solara.logger.header("Solara Dashboard")
        else
            open("brand/brand.html?brand_key=#{brand_key}&source=local", port)
            Solara.logger.header("Solara Dashboard for #{brand_key}")
        end
    end
    
    private

    def open(page, port = 8000)
        DashboardServer.new(page, port, FilePath.dashboard).start
    end
end