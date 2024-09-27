class InfoPlistStringCatalogManager {
    constructor(jsonData) {
        this.data = jsonData;
        this.localizations = {};
        this.extractLocalizations();
    }

    extractLocalizations() {
        for (const [key, details] of Object.entries(this.data.strings)) {
            for (const [lang, localization] of Object.entries(details.localizations)) {
                const formattedKey = `${key}.${lang}`;
                this.localizations[formattedKey] = localization.stringUnit.value;
            }
        }
        return this.localizations
    }
}

export default InfoPlistStringCatalogManager;
