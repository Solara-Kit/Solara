Dir.glob("#{__dir__}/core/scripts/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/core/scripts/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/core/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/core/doctor/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/core/aliases/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/core/dashboard/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/core/brands/*.rb").each { |file| require file }

require 'json'
require 'xcodeproj'

class SolaraInitializer

    def initialize(brand_key, brand_name)
        @brand_key = brand_key
        @brand_name = brand_name
        @project_root = SolaraSettingsManager.instance.project_root
    end

    def init
        Solara.logger.header("Initializing Solara")
        confirm_init_if_necessary

        ProjectDoctor.new.visit

        message = "Initialized #{SolaraSettingsManager.instance.platform} successfully."
        SolaraManager.new.onboard(@brand_key, @brand_name, init: true, success_message: message)
    end

    def confirm_init_if_necessary
        brand_path = FilePath.brands
        # Check if Solara path exists
        if Dir.exist?(brand_path)
            Solara.logger.warn("Solara already initialized! Be aware that reinitializing will delete all current brands!")
            Solara.logger.warn("Don't say I didn't warn you!")
            Solara.logger.warn("Do you want to proceed? (y/n)")
            confirmation = STDIN.gets.chomp.downcase

            unless confirmation == 'y'
                Solara.logger.info("Solara initialization cancelled.")
                exit 1
            end
            FileManager.delete_if_exists(brand_path)
        end
    end

end
