Dir.glob("#{__dir__}/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/core/scripts/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/core/scripts/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/core/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/core/doctor/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/core/aliases/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/core/dashboard/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/core/brands/*.rb").each { |file| require file }

require 'json'
require 'xcodeproj'

class SolaraManager

    def initialize
    end

    def init(brand_key, brand_name)
        SolaraInitializer.new(brand_key, brand_name).init
    end

    def import(configurations)
        BrandImporter.new.start(configurations)
    end

    def export(brand_keys, path)
        BrandExporter.new.start(brand_keys, path)
    end

    def status
        SolaraStatusManager.new.start
    end

    def onboard(brand_key, brand_name, init: false, clone_brand_key: nil, open_dashboard: true, success_message: nil)
        begin
            Solara.logger.header("Onboarding #{brand_key}")

            if !init && BrandsManager.instance.exists(brand_key)
                Solara.logger.fatal("Brand with key (#{brand_key}) already added to brands!")
                return
            end

            BrandOnboarder.new.onboard(brand_key, brand_name, clone_brand_key: clone_brand_key)

            switch(brand_key, ignore_health_check: true)


            clone_message = clone_brand_key.nil? || clone_brand_key.empty? ? '.' : ", cloned from #{clone_brand_key}."
            message = success_message || "Onboarded #{brand_key} successfully#{clone_message}"
            Solara.logger.success(message)

            if open_dashboard
                Solara.logger.success("Openning the dashboard for #{brand_key} to complete its details.")
                dashboard(brand_key)
            end
        rescue => e
            # Rollback this brand
            offboard(brand_key, confirm: false)
            Solara.logger.debug("Performed rollback for (#{brand_key}).")
            raise e
        end
    end

    def offboard(brand_key, confirm: true)
        BrandOffboarder.new.offboard(brand_key, confirm: confirm)
    end

    def switch(brand_key, ignore_health_check: false)
        BrandSwitcher.new(brand_key, ignore_health_check: ignore_health_check).start
    end

    def dashboard(brand_key, port = 8000)
        DashboardManager.new.start(brand_key, port)
    end

    def doctor(brand_key = nil, print_logs: true)
        keys = brand_key.nil? || brand_key.empty? ? [] : [brand_key]
        DoctorManager.new.visit_brands(keys, print_logs: print_logs)
    end

    def sync_brand_with_template(brand_key)
        BrandOnboarder.new.sync_with_template(brand_key)
    end

end