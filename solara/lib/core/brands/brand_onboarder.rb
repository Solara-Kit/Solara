Dir[File.expand_path('scripts/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('../template/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('platform/android/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('platform/ios/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('platform/flutter/*.rb', __dir__)].each { |file| require_relative file }

class BrandOnboarder
    def initialize(brand_key, brand_name, clone_brand_key: nil)
        @brand_key = brand_key
        @brand_name = brand_name
        @clone_brand_key = clone_brand_key
    end

    def onboard
        if @clone_brand_key.nil? || @clone_brand_key.empty?
            generate_brand_template
        else
            clone_brand
        end
        add_to_brands_list
    end

    def generate_brand_template
        Solara.logger.debug("Onboarding #{@brand_key} from template.")

        template_dir = FilePath.template_brands
        target_dir = FilePath.brand(@brand_key)
        config_file = FilePath.template_config

        generator = ProjectTemplateGenerator.new(template_dir, target_dir, config_file)
        generator.create_project
    end

    def clone_brand
        Solara.logger.debug("Cloning #{@clone_brand_key} to #{@brand_key}")
        source = FilePath.brand(@clone_brand_key)
        destination = FilePath.brand(@brand_key)

        FileManager.delete_if_exists(destination)
        FolderCopier.new(source, destination).copy
    end

    def add_to_brands_list
        BrandsManager.instance.add_brand(@brand_name, @brand_key)
    end

end

