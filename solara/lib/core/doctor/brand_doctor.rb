Dir.glob("#{__dir__}/*.rb").each { |file| require file }
Dir.glob("#{__dir__}/validator/template/*.rb").each { |file| require file }

class BrandDoctor
    def initialize
    end

    def visit(brand_keys = [], print_logs: true)
        keys = brand_keys.empty? ? BrandsManager.instance.brands_list.map { |brand| brand['key'] } : brand_keys
        issues = []
        has_template_errors = false

        keys.each do |brand_key|
            validator = TemplateValidator.new(FilePath.brand(brand_key), FilePath.template_validation_config)
            errors = validator.validate

            errors.each { |error|
                issues << Issue.error(error)
            }
            has_template_errors = true unless issues.select { |issue| issue.type == Issue::ERROR }.empty?
        end

        # Validate settings only if all validations so far are passed to avoid files issues
        unless has_template_errors
            issues += BrandSettingsValidatorManager.new.validate
        end

        if print_logs && !issues.empty?
            Solara.logger.title("Health Check Result")

            issues.sort!.each { |issue|
                case issue.type
                when Issue::ERROR
                    Solara.logger.failure(issue.to_s)
                when Issue::WARNING
                    Solara.logger.warn(issue.to_s)
                else
                    Solara.logger.failure(issue.to_s)
                    issues.sort!
                end
            }
        end

        issues.sort!
    end

    def validate_brand(brand_key, strategies = [])
        Solara.logger.start_step("Brand Health Check: #{brand_key}")

        project_path = FilePath.brand(brand_key)
        issues = []

        strategies.each do |strategy|
            Solara.logger.debug("Running #{strategy.class.name}...")
            begin
                strategy.validate(project_path)
                Solara.logger.debug("#{strategy.class.name} passed.")
            rescue => e
                issues << Issue.error("#{e.message} (#{strategy.class.name})")
            end
        end

        Solara.logger.end_step("Brand Health Check #{brand_key}")
        issues
    end
end

class Issue < StandardError
    ERROR = 'ERROR'
    WARNING = 'WARNING'

    attr_reader :type, :error

    def initialize(type, error)
        @type = type
        @error = error
    end

    def to_s
        "#{@type}: #{@error}"
    end

    def <=>(other)
        [type, error] <=> [other.type, other.error]
    end

    def self.error(error)
        Issue.new(ERROR, error)
    end

    def self.warning(error)
        Issue.new(WARNING, error)
    end
end
