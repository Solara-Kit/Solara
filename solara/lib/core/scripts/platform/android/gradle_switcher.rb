Dir[File.expand_path('../../*.rb', __dir__)].each { |file| require_relative file }
require 'fileutils'
require 'json'

class GradleSwitcher
    KOTLIN_IMPORTS = <<-KOTLIN
import java.io.FileInputStream
import java.util.Properties

    KOTLIN

    KOTLIN_PROPERTIES_LOADER = <<-KOTLIN
val brandProperties = Properties().apply {
    load(FileInputStream(file("../#{FilePath.artifacts_dir_name}/brand.properties")))
}
    KOTLIN

    GROOVY_PROPERTIES_LOADER = <<-GROOVY
project.ext {
    brandProperties = new Properties()
    brandProperties.load(new FileInputStream(file("../#{FilePath.artifacts_dir_name}/brand.properties")))
}
    GROOVY

    KOTLIN_APPLICATION_ID = 'applicationId = brandProperties.getProperty("applicationId")'
    GROOVY_APPLICATION_ID = "applicationId = project.ext.brandProperties.getProperty('applicationId')"

    KOTLIN_VERSION_NAME = 'versionName = brandProperties.getProperty("versionName")'
    GROOVY_VERSION_NAME = "versionName = project.ext.brandProperties.getProperty('versionName')"

    KOTLIN_VERSION_CODE = 'versionCode = brandProperties.getProperty("versionCode").toInt()'
    GROOVY_VERSION_CODE = "versionCode = project.ext.brandProperties.getProperty('versionCode').toInteger()"

    DEFAULT_SOURCE_SETS = ['src/main/res', "src/main/#{FilePath.artifacts_dir_name}"]

    def initialize(brand_key)
        @brand_key = brand_key
        @is_kotlin_gradle = FilePath.is_koltin_gradle
        @brand_config = JSON.parse(File.read(FilePath.android_config(brand_key)))
        @source_sets = (@brand_config['sourceSets'] || []).concat(DEFAULT_SOURCE_SETS).uniq
    end

    def switch
        Solara.logger.start_step("Switch app/build.gradle")
        gradle_file = FilePath.android_app_gradle
        gradle_content = File.read(gradle_file)

        update_gradle(gradle_file, gradle_content)
        add_source_sets(gradle_file)
        update_keystore_config(gradle_file)
        Solara.logger.end_step("Switch app/build.gradle")
    end

    private

    def update_gradle(gradle_file, gradle_content)
        properties_loader = @is_kotlin_gradle ? KOTLIN_PROPERTIES_LOADER : GROOVY_PROPERTIES_LOADER

        if @is_kotlin_gradle
            # Add imports for Kotlin
            unless gradle_content.include?("import java.io.FileInputStream")
                insert_position = gradle_content.index(/\s*(plugins|android)\s*{/)
                if insert_position.nil?
                    raise "Could not find a suitable position to insert imports in #{FilePath.gradle_name}"
                end
                gradle_content.insert(insert_position, KOTLIN_IMPORTS)
            end
        end

        insert_position = gradle_content.index(/\s*android\s*{/)
        if insert_position.nil?
            raise "Could not find android block in #{FilePath.gradle_name}"
        end

        unless gradle_content.include?(@is_kotlin_gradle ? "val brandProperties" : "brandProperties = new Properties")
            gradle_content.insert(insert_position + 1, properties_loader)
        end

        android_block_regex = /(android\s*\{(?:[^{}]|\{(?:[^{}]|\{[^{}]*\})*\})*\})/m
        updated_android_block = gradle_content.match(android_block_regex)[1]
                                    .gsub(
                                        /applicationId\s+=\s+.*/,
                                        @is_kotlin_gradle ? KOTLIN_APPLICATION_ID : GROOVY_APPLICATION_ID
                                    )
                                    .gsub(
                                        /versionName\s+=\s+.*/,
                                        @is_kotlin_gradle ? KOTLIN_VERSION_NAME : GROOVY_VERSION_NAME
                                    ).gsub(
            /versionCode\s+=\s+.*/,
            @is_kotlin_gradle ? KOTLIN_VERSION_CODE : GROOVY_VERSION_CODE
        )

        gradle_content.sub!(android_block_regex, updated_android_block)
        File.write(gradle_file, gradle_content)
        Solara.logger.debug("Updated #{gradle_file} (#{@is_kotlin_gradle ? 'Kotlin' : 'Groovy'}) to use brand.properties")
    end

    def add_source_sets(gradle_file)
        content = File.read(gradle_file)

        source_sets_string = @source_sets.map { |dir| "\"#{dir}\"" }.join(', ')
        kotlin_pattern = /(sourceSets\s*\{\s*getByName\s*\(\s*"main"\s*\)\s*\{\s*res\s*\.\s*srcDirs\s*\(.*?\)\s*\}\s*\})/m
        groovy_pattern = /(sourceSets\s*\{\s*main\s*\{\s*res\s*\.\s*srcDirs\s*=.*?\s*\}\s*\})/m

        new_config = generate_source_sets(source_sets_string)

        modified_content = if @is_kotlin_gradle
                               if content.match?(kotlin_pattern)
                                   content.gsub(kotlin_pattern) do |match|
                                       indent = match[/^\s*/]
                                       "#{indent}#{new_config.strip}"
                                   end
                               else
                                   content.sub(/(\s*android\s*\{)/) { "#{$1}\n    #{new_config.strip}" }
                               end
                           else
                               if content.match?(groovy_pattern)
                                   content.gsub(groovy_pattern) do |match|
                                       indent = match[/^\s*/]
                                       "#{indent}#{new_config.strip}"
                                   end
                               else
                                   content.sub(/(\s*android\s*\{)/) { "#{$1}\n    #{new_config.strip}" }
                               end
                           end

        File.write(gradle_file, modified_content)
        Solara.logger.debug("Source sets configuration updated successfully.")
    end

    def generate_source_sets(source_sets_string)
        if @is_kotlin_gradle
            <<-KOTLIN
        sourceSets {
            getByName("main") {
                res.srcDirs(listOf(#{source_sets_string}))
            }
        }
            KOTLIN
        else
            <<-GROOVY
        sourceSets {
            main {
                res.srcDirs = [#{source_sets_string}]
            }
        }
            GROOVY
        end
    end

    def update_keystore_config(gradle_file)
        # We need to apply code signing only if the user has provided its config
        path = FilePath.brand_signing(@brand_key, Platform::Android)
        signing = JSON.parse(File.read(path))
        if signing['storeFile'].empty?
            return
        end

        content = File.read(gradle_file)

        # Check if the configuration is already applied
        if content.include?('brandProperties.getProperty("keystore.storeFile")') ||
            content.include?('project.ext.brandProperties.getProperty("keystore.storeFile")')
            Solara.logger.debug("Keystore configuration already applied. Skipping update.")
            return
        end

        new_config = generate_keystore_config

        signing_config_pattern = /(signingConfigs\s*\{(?:[^{}]|\{(?:[^{}]|\{[^{}]*\})*\})*\})/m
        build_types_pattern = /(buildTypes\s*\{(?:[^{}]|\{(?:[^{}]|\{[^{}]*\})*\})*\})/m

        modified_content = content.dup

        # Remove existing buildTypes block if it exists
        modified_content.gsub!(build_types_pattern, '')

        # Update or add signingConfigs and buildTypes
        if modified_content.match?(signing_config_pattern)
            modified_content.gsub!(signing_config_pattern, new_config)
        else
            modified_content.sub!(/(\s*android\s*\{)/) { "#{$1}\n    #{new_config.strip}" }
        end

        if content != modified_content
            File.write(gradle_file, modified_content)
            Solara.logger.debug("Keystore configuration updated successfully.")
        else
            Solara.logger.debug("No changes were necessary for keystore configuration.")
        end
    end

    def generate_keystore_config
        if @is_kotlin_gradle
            <<-KOTLIN
        signingConfigs {
            create("release") {
                storeFile = file(brandProperties.getProperty("storeFile"))
                storePassword = brandProperties.getProperty("storePassword")
                keyAlias = brandProperties.getProperty("keyAlias")
                keyPassword = brandProperties.getProperty("keyPassword")
            }
        }
        buildTypes {
            getByName("release") {
                signingConfig = signingConfigs.getByName("release")
            }
            getByName("debug") {
                isDebuggable = true
            }
        }
            KOTLIN
        else
            <<-GROOVY
        signingConfigs {
            release {
                storeFile file(project.ext.brandProperties.getProperty("storeFile"))
                storePassword project.ext.brandProperties.getProperty("storePassword")
                keyAlias project.ext.brandProperties.getProperty("keyAlias")
                keyPassword project.ext.brandProperties.getProperty("keyPassword")
            }
        }
        buildTypes {
            release {
                signingConfig signingConfigs.release
            }
            debug {
                debuggable true
            }
        }
            GROOVY
        end
    end
end