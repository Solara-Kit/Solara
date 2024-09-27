Dir.glob("#{__dir__}/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/validator/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/brand/*.rb").each { |file| require file }

class DoctorManager
    def initialize
    end

    def visit_brands(brand_keys = [], print_logs: true)
        Solara.logger.header("Brand Doctor")
        ensure_initialized!
        BrandDoctor.new.visit(brand_keys, print_logs: print_logs)
    end

    def visit_project!
        Solara.logger.header("Project Doctor")
        Solara.logger.start_step("Project Health Check")
        ensure_initialized!
        ProjectDoctor.new.visit
        Solara.logger.end_step("Project Health Check")
    end

    def ensure_switched
        unless File.exist?(FilePath.current_brand)
message = <<-MESSAGE
It looks like you haven't switched to a brand yet!
You can open the dashboard by running 'solara dashboard' in your terminal and make the switch there.
Alternatively, you can execute 'solara switch YOUR_BRAND_KEY_HERE' in your terminal.
MESSAGE
            Solara.logger.error(message)
            return false
        end
        return true
   end

    private

    def ensure_initialized!
        brands = FilePath.brands
        brands_list = FilePath.brands_list
        platform = SolaraSettingsManager.instance.platform
        unless File.exist?(brands) &&  File.exist?(brands_list) && !platform.nil? && !platform.empty?
            Solara.logger.error("Solara is not initialized here. Please run 'solara init' to initialize.")
            exit 1
        end
    end

end
