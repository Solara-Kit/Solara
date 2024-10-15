class SolaraStatusManager

    def start
        current_brand_draft
        puts
        brands_list
        doctor
    end

    def current_brand_draft
        unless DoctorManager.new.ensure_switched
            return
        end

        current_brand = BrandsManager.instance.current_brand
        unless current_brand
            return
        end

        Solara.logger.title("Current Brand Status")

        content_changed = current_brand['content_changed']

        unless content_changed
            Solara.logger.info("Current brand configurations are up-to-date")
            return
        end

        Solara.logger.warn("Changes for the current brand have been drafted!")
        Solara.logger.info("To apply these changes, please use one of the following methods:")
        message = <<-MESSAGE
        1. Run this command in your terminal:
        
            solara switch -k #{current_brand['key']}
        
        2. Alternatively, open the dashboard by executing this command in your terminal:
        
            solara dashboard -k #{current_brand['key']}
     
            Then, click the "Sync" button.
        MESSAGE
        Solara.logger.info(message)
    end

    def brands_list
        Solara.logger.title("Brands List")

        brands_list = BrandsManager.instance.brands_list.each_with_index.map { |brand, index|
            "#{index + 1}. Key:  #{brand['key']}\n   Name: #{brand['name']}\n"
        }
        brands_list.each do |brand|
            Solara.logger.info(brand)
        end
    end

    def doctor
        SolaraManager.new.doctor
    end
end