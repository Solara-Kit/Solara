class AndroidManifestSwitcher
    def initialize
    end

    def switch(config)
        Solara.logger.start_step("Switch AndroidManifest")
        manifest_file = FilePath.android_manifest
        if File.exist?(manifest_file)
            manifest_content = File.read(manifest_file)
            updated_manifest = update_app_name(manifest_content, config)
            File.write(manifest_file, updated_manifest)
            Solara.logger.debug("Updated #{FilePath.android_manifest} to use string resource for app name")
        else
            Solara.logger.debug("❌ #{FilePath.android_manifest} not found. Skipping manifest update.")
        end
        Solara.logger.end_step("Switch AndroidManifest")
    end

    private

    def update_app_name(manifest_content, config)
        manifest_content.gsub(/android:label="[^"]+"/, 'android:label="@string/app_name"')
    end
end