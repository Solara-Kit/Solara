Dir[File.expand_path('scripts/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('../template/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('platform/android/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('platform/ios/*.rb', __dir__)].each { |file| require_relative file }
Dir[File.expand_path('platform/flutter/*.rb', __dir__)].each { |file| require_relative file }

class BrandOnboarder

    def onboard(brand_key, brand_name, clone_brand_key: nil)
        if clone_brand_key.nil? || clone_brand_key.strip.empty?
            generate_from_template(brand_key)
        else
            clone_brand(brand_key, clone_brand_key: clone_brand_key)
        end
        add_to_brands_list(brand_key, brand_name)
    end

    def sync_with_template(brand_key)
        generator = template_generator(brand_key)
        generator.sync_with_template
    end

    def clone_brand(brand_key, clone_brand_key:)
        Solara.logger.debug("Cloning #{clone_brand_key} to #{brand_key}")
        source = FilePath.brand(clone_brand_key)
        destination = FilePath.brand(brand_key)

        FileManager.delete_if_exists(destination)
        FolderCopier.new(source, destination).copy
    end

    def add_to_brands_list(brand_key, brand_name)
        BrandsManager.instance.add_brand(brand_name, brand_key)
    end

    def generate_from_template(brand_key)
        Solara.logger.debug("Onboarding #{brand_key} from template.")

        generator = template_generator(brand_key)
        generator.create_project
    end

    def template_generator(brand_key)
        template_dir = FilePath.template_brands
        target_dir = FilePath.brand(brand_key)
        config_file = FilePath.template_config

        ProjectTemplateGenerator.new(template_dir, target_dir, config_file)
    end

end

