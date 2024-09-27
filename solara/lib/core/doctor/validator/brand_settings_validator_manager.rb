class BrandSettingsValidatorManager

    def initialize
        @validator = BrandSettingsValidator.new
    end

    def validate
        issues = ios_config
        issues += ios_signing
        issues += android_config
        issues += android_signing
        issues + brand_config
    end

    def ios_config
        issues = @validator.validate_properties(
            %w[MARKETING_VERSION BUNDLE_VERSION],
            :ios_config,
            issue_type: Issue::ERROR)

        issues += @validator.validate_single_property(
            'PRODUCT_BUNDLE_IDENTIFIER',
            :ios_config,
            issue_type: Issue::ERROR)

        issues + @validator.validate_property_duplicates(
            'PRODUCT_BUNDLE_IDENTIFIER',
            :ios_config,
            issue_type: Issue::ERROR)
    end

    def ios_signing
        @validator.validate_properties(
            %w[CODE_SIGN_IDENTITY DEVELOPMENT_TEAM PROVISIONING_PROFILE_SPECIFIER CODE_SIGN_STYLE CODE_SIGN_ENTITLEMENTS],
            :ios_brand_signing,
            issue_type: Issue::WARNING)
    end

    def android_signing
        @validator.validate_properties(
            %w[storeFile keyAlias storePassword keyPassword],
            :android_brand_signing,
            issue_type: Issue::WARNING)
    end

    def android_config
        issues = @validator.validate_properties(
            %w[versionName versionCode],
            :android_config,
            issue_type: Issue::ERROR)

        issues += @validator.validate_single_property(
            'applicationId',
            :android_config,
            issue_type: Issue::ERROR)

        issues + @validator.validate_property_duplicates(
            'applicationId',
            :android_config,
            issue_type: Issue::ERROR)
    end

    def brand_config
         @validator.validate_single_property(
            'brandName',
            :brand_config,
            issue_type: Issue::ERROR)
    end

end