require 'thor'
require 'fileutils'
Dir['*.rb'].each { |file| require_relative file }
Dir.glob("#{__dir__}/core/scripts/*.rb").each { |file| require file }
require 'solara_manager'
require 'rubygems'

module Solara
    ROOT = Pathname.new(File.expand_path('..', __FILE__))
    PROJECT_ROOT = Dir.pwd

    class << self
        attr_reader :logger
        attr_reader :verbose

        def verbose=(value)
            @verbose = value
            @logger.verbose = value
        end
    end

    @logger = SolaraLogger.new
    @verbose = false

    class Setup
        def setup
            SolaraSettingsManager.instance.root = ROOT
            SolaraSettingsManager.instance.project_root = PROJECT_ROOT

            Solara.logger.debug("Solara installation at path: #{PROJECT_ROOT}")
        end
    end

    class CLI < Thor
        class_option :verbose, type: :boolean, :aliases => "-v", default: false, desc: 'Run verbosely'

        def initialize(*args)
            super
            setup
        end

        def self.exit_on_failure?
            true
        end

        desc "init -p YOUR_PLATFORM -k YOUR_BRAND_KEY -n YOUR_BRAND_NAME",
             "Initialize Solara. Options: #{Platform.all.join(', ')}"
        method_option :brand_key, :type => :string, :aliases => "-k"
        method_option :brand_name, :type => :string, :aliases => "-n"
        method_option :platform, :type => :string, :aliases => "-p"

        def init
            brand_key = options['brand_key']
            brand_name = options['brand_name']
            input_platform = options['platform']

            if !brand_key || !brand_name
                Solara.logger.warn('To set up Solara, we need to onboard an initial brand. Please provide the following details for your first brand:')
            end

            brand_key = validate_brand_key(brand_key, ignore_brand_check: true)
            brand_name = validate_brand_name(brand_name)

            platform = if !input_platform.nil?
                           input_platform
                       else
                           PlatformDetector.new.platform
                       end

            platform = platform.to_s.downcase

            SolaraSettingsManager.instance.platform = platform
            SolaraManager.new.init(brand_key, brand_name)
        end

        desc "status", "Check the current status of Solara. The results may include information about the brand's current standing, the list of brands, and additional details."

        def status
            check_project_health
            SolaraManager.new.status
        end

        desc "import -configurations CONFIGURATIONS_JSON_FILE --brand_key YOUR_BRAND_KEY", "Import the brand's configurations. If the brand is existing, it will be updated with these configurations, otherwise, a new brand will be onboarded."

        method_option :configurations, :type => :array, :aliases => "-c"
        def import
            check_project_health

            configurations = options['configurations']

            SolaraManager.new.import(configurations)
        end


        desc "export --brand_key YOUR_BRAND_KEY --directory DIRECTORY", "Export the brand's configurations. The brand details will be saved to a JSON file at the specified location."
        method_option :brand_keys, :type => :array, :aliases => "-k"
        method_option :directory, :type => :string, :aliases => "-d"
        def export
            check_project_health

            brand_keys = options['brand_keys']
            directory = options['directory']


            SolaraManager.new.export(brand_keys, directory)
        end

        desc "onboard -k YOUR_BRAND_KEY -n YOUR_BRAND_NAME", "Onboard a new brand"
        method_option :brand_key, :type => :string, :aliases => "-k"
        method_option :brand_name, :type => :string, :aliases => "-n"
        method_option :clone, :type => :string, :aliases => "-c"

        def onboard
            check_project_health

            brand_key = options['brand_key']
            brand_name = options['brand_name']
            clone_brand_key = options['clone']

            brand_key = validate_brand_key(brand_key, ignore_brand_check: true)
            brand_name = validate_brand_name(brand_name)

            unless clone_brand_key.nil? || clone_brand_key.empty?
                clone_brand_key = validate_brand_key(clone_brand_key, message: "Clone brand key is not existing, please enter correct key: ")
            end

            SolaraManager.new.onboard(brand_key, brand_name, clone_brand_key: clone_brand_key)
        end

        desc "offboard -k YOUR_BRAND_KEY", "Offboard a brand by deleting it from brands."
        method_option :brand_key, :type => :string, :aliases => "-k"

        def offboard
            check_project_health
            brand_key = options['brand_key']
            brand_key = validate_brand_key(brand_key)
            SolaraManager.new.offboard(brand_key)
        end

        desc "`switch -k YOUR_BRAND_KEY", "Switch to a brand."
        method_option :brand_key, :type => :string, :aliases => "-k"

        def switch
            check_project_health
            brand_key = options['brand_key']
            brand_key = validate_brand_key(brand_key)
            begin
                SolaraManager.new.switch(brand_key)
            rescue Issue => e
                Solara.logger.fatal("Switching to #{brand_key} failed.")
                exit 1
            end

        end

        desc "`sync", "Sync the changes of the current brand through switching."
        def sync
            check_project_health

            current_brand = BrandsManager.instance.current_brand
            unless current_brand
                Solara.logger.fatal("Please switch a brand first in order to enable synchronization.")
                exit 1
            end
            brand_key = current_brand['key']

            begin
                SolaraManager.new.switch(brand_key)
            rescue Issue => e
                Solara.logger.fatal("Switching to #{brand_key} failed.")
                exit 1
            end
        end

        desc "dashboard -k YOUR_OPTIONAL_BRAND_KEY", "Open the dashboard for a brand if brank_key is provided."
        method_option :brand_key, :type => :string, :aliases => "-k"
        method_option :port, :type => :numeric, :aliases => "-p"

        def dashboard
            check_project_health
            brand_key = options['brand_key']
            brand_key = validate_brand_key(brand_key, ignore_if_nil: true)
            SolaraManager.new.dashboard(brand_key, options['port'] || 8000)
        end

        desc "doctor -k YOUR_BRAND_KEY", "Visit Doctor for a brand if brankd_key provided."
        method_option :brand_key, :type => :string, :aliases => "-k"

        def doctor
            check_project_health
            brand_key = options['brand_key']
            brand_key = validate_brand_key(brand_key, ignore_if_nil: true)
            SolaraManager.new.doctor(brand_key)
        end

        private

        # Ensure the platform is set when Solara is initialized but the platform is not set
        # This happens in scenarios like cloning the project and running Solara, In this case the
        # platfrom is not set yet.
        def ensure_platform
            brands = FilePath.brands
            platform = SolaraSettingsManager.instance.platform || ''
            if File.exist?(brands) && platform.empty?
                SolaraSettingsManager.instance.platform = PlatformDetector.new.platform
            end
        end

        def check_project_health(ensure_switched: false)
            manager = DoctorManager.new
            manager.visit_project!
            manager.ensure_switched if ensure_switched
        end

        def validate_brand_key(brand_key, ignore_if_nil: false, ignore_brand_check: false, message: nil)
            if ignore_if_nil && brand_key.nil?
                return brand_key
            end

                if brand_key.nil? || brand_key.empty? || (!ignore_brand_check && !BrandsManager.instance.exists(brand_key))
                message = message || (brand_key.nil? || brand_key.empty? ? "Please enter brand key: " : "Please enter existing brand key: ")
                brand_key = TerminalInputManager.new.get_validated(message) do |input|
                    # Validate that it starts with a letter and contains no spaces
                    unless input.match?(/^[a-zA-Z][\S]*$/)
                        Solara.logger.failure("Invalid brand key.  It must start with at least a letter and contain no spaces.")
                        next false # Use `next` to continue the loop
                    end

                    # Check if the brand exists in the list
                    if !ignore_brand_check && !BrandsManager.instance.exists(input)
                        Solara.logger.failure("Brand key does not exist.")
                        next false # Use `next` to continue the loop
                    end

                    true # Valid input and brand exists
                end
            end

            # If brand_key is valid and exists, return it
            brand_key
        end

        def validate_brand_name(brand_name)
            if brand_name.nil? || brand_name.empty?
                message = "Please enter brand name: "
                return TerminalInputManager.new.get(message)
            end
            brand_name
        end


        def setup
            Solara.logger.verbose = options[:verbose] || false

            ensure_platform

            # Solara version is mandatory because the structure and logic may change in the future and need to migrate.
            SolaraVersionManager.instance.version = Gem.loaded_specs['solara'].version.to_s
        end

    end

end