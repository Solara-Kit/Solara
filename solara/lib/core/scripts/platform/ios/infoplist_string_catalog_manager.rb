require 'json'

module StringCatalogUtils
  def load_string_catalog(path)
    @path = path
    JSON.parse(File.read(path))
  end

  def get_value(data, key, target, language)
    lang = language || data['sourceLanguage']
    localizations = data.dig('strings', key, 'localizations', lang)

    unless localizations && localizations['stringUnit']
      error_message = "The default language is #{lang}, but no localizations are available for key '#{key}'. Please address this issue in {@path}. You can easily open the file in Xcode to make the necessary adjustments."
      Solara.logger.fatal(error_message)
      exit 1
    end

    string_unit = localizations['stringUnit']
    string_unit[target]
  end

  def has_value?(data, key, language)
    state = get_value(data, key, 'state', language)
    value = get_value(data, key, 'value', language)
    state != 'new' && value != ''
  end
end

class InfoPListStringCatalogManager
  include StringCatalogUtils

  def initialize(string_catalog_path)
    @string_catalog_path = string_catalog_path
    @data = load_string_catalog(@string_catalog_path)
  end

  def update(result, can_remove_extra_values: true)

    update_localizations(result)

    remove_unused_localizations(result) if can_remove_extra_values

    File.write(@string_catalog_path, JSON.pretty_generate(@data))
  end

  def source_language
    @data['sourceLanguage']
  end

  def get(key, language: nil)
    get_value(@data, key, 'value', language)
  end

  private

  def update_localizations(result)
    result.each do |base_key, languages|
      next unless @data['strings'].key?(base_key)

      languages.each do |lang_code, value|
        initialize_localization(base_key, lang_code)
        update_string_unit(base_key, lang_code, value)
      end
    end
  end

  def initialize_localization(base_key, lang_code)
    @data['strings'][base_key]['localizations'][lang_code] ||= {
      "stringUnit" => {
        "state" => "new",
        "value" => ""
      }
    }
  end

  def update_string_unit(base_key, lang_code, value)
    state = value.empty? ? 'new' : 'translated'
    @data['strings'][base_key]['localizations'][lang_code]['stringUnit'].merge!({
      'state' => state,
      'value' => value
    })
  end

  def remove_unused_localizations(result)
    @data['strings'].each do |base_key, data|
      data['localizations'].each_key do |lang_code|
        data['localizations'].delete(lang_code) unless result.dig(base_key, lang_code)
      end
    end
  end
end

class InfoPListStringCatalogValidator
  include StringCatalogUtils

  def initialize(string_catalog_path)
    @string_catalog_path = string_catalog_path
    @data = load_string_catalog(@string_catalog_path)
    @source_language = @data['sourceLanguage']
  end

  def validate
    issues = []

    @data['strings'].keys.each do |key|
      languages = @data['strings'][key]['localizations'].keys
      languages.each do |language|
        validation_error = validate_key(key, language)
        if validation_error
          issues << (language == @source_language ? Issue.error(validation_error) : Issue.warning(validation_error))
        end
      end
    end

    issues
  end

  private

  def validate_key(key, language)
    return nil if has_value?(@data, key, language)

    "The value for '#{key}' is not translated in #{@string_catalog_path}. " \
    "To resolve this issue, please open the dashboard and update the entry for '#{key}.#{@source_language}' in section 'iOS InfoPlist.xcstrings Configuration'. " \
    "If you prefer, you can manually add a value and mark its state as 'translated'."
  end
end

module InfoPListKey
  BUNDLE_NAME = 'CFBundleName'
  BUNDLE_DISPLAY_NAME = 'CFBundleDisplayName'
end