class BrandOffboarder

    def offboard(brand_key, confirm: true)
        unless BrandsManager.instance.exists(brand_key)
            Solara.logger.fatal("Brnad key #{brand_key} doesn't exist!")
            return
        end

        if confirm
            Solara.logger.warn("Are you sure you need to offboard #{brand_key} and delete all its configurations? (y/n)")
            confirmation = STDIN.gets.chomp.downcase

            unless confirmation == 'y'
                Solara.logger.info("Offboarding #{brand_key} cancelled.")
                return
            end
        end
        BrandsManager.instance.offboard(brand_key)
        Solara.logger.success("Offboarded #{brand_key} successfully.")
        is_current_brand = BrandsManager.instance.is_current_brand(brand_key)
        SolaraManager.new.switch(BrandsManager.instance.first_brand_key, ignore_health_check: true) if is_current_brand
    end

end