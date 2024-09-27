import Ajv from 'https://cdn.skypack.dev/ajv@8.11.0';

class BrandRemoteSource {
    constructor() {
    }

    async createNewBrandConfogurations() {
        const configurations_template = `
        [
  {
    "key": "theme.json",
    "name": "Theme Configuration",
    "inputType": "color",
    "content": {
      "colors": {
        "primary": "#CAAC16",
        "secondary": "#5AC8FA",
        "background": "#FFFFFF",
        "surface": "#F2F2F7",
        "error": "#FF3B30",
        "onPrimary": "#FFFFFF",
        "onSecondary": "#000000",
        "onBackground": "#000000",
        "onSurface": "#000000",
        "onError": "#FFFFFF"
      },
      "typography": {
        "fontFamily": {
          "regular": "",
          "medium": "",
          "bold": ""
        },
        "fontSize": {
          "small": 12,
          "medium": 16,
          "large": 20,
          "extraLarge": 24
        }
      },
      "spacing": {
        "small": 8,
        "medium": 16,
        "large": 24,
        "extraLarge": 32
      },
      "borderRadius": {
        "small": 4,
        "medium": 8,
        "large": 12
      },
      "elevation": {
        "none": 0,
        "low": 2,
        "medium": 4,
        "high": 8
      }
    }
  },
  {
    "key": "brand_config.json",
    "name": "Brand Configuration",
    "inputType": "text",
    "content": {}
  },
  {
    "key": "android_config.json",
    "name": "Android Configuration",
    "inputType": "text",
    "content": {
      "applicationId": "",
      "versionName": "1.0.0",
      "versionCode": 1,
      "sourceSets": []
    }
  },
  {
    "key": "android_signing.json",
    "name": "Android Signing",
    "inputType": "text",
    "content": {
      "storeFile": "",
      "keyAlias": "",
      "storePassword": "",
      "keyPassword": ""
    }
  },
  {
    "key": "ios_config.json",
    "name": "iOS Configuration",
    "inputType": "text",
    "content": {
      "PRODUCT_BUNDLE_IDENTIFIER": "",
      "MARKETING_VERSION": "1.0.0",
      "BUNDLE_VERSION": 1,
      "APL_MRCH_ID": ""
    }
  },
  {
    "key": "ios_signing.json",
    "name": "iOS Signing",
    "inputType": "text",
    "content": {
      "CODE_SIGN_IDENTITY": "",
      "DEVELOPMENT_TEAM": "",
      "PROVISIONING_PROFILE_SPECIFIER": "",
      "CODE_SIGN_STYLE": "Automatic",
      "CODE_SIGN_ENTITLEMENTS": ""
    }
  },
  {
    "key": "ios_signing.json",
    "name": "iOS Signing",
    "inputType": "text",
    "content": {
      "CODE_SIGN_IDENTITY": "",
      "DEVELOPMENT_TEAM": "",
      "PROVISIONING_PROFILE_SPECIFIER": "",
      "CODE_SIGN_STYLE": "Automatic",
      "CODE_SIGN_ENTITLEMENTS": ""
    }
  }
]
`;
        return JSON.parse(configurations_template);
    }

    async getBrandConfigurationsJsonFromDirectory(dirHandle) {
        const schema = await this.fetchBrandConfigurationsSchema();

        const ajv = new Ajv();
        const validate = ajv.compile(schema);

        const text = await dirHandle.text();
        let json;

        try {
            json = JSON.parse(text);
        } catch (e) {
            console.error("Invalid JSON:", e);
            return null;
        }

        const valid = validate(json);

        if (valid) {
            return json;
        } else {
            console.error("Schema validation failed:", validate.errors);
            const errorMessages = validate.errors.map(error => `${error.instancePath}: ${error.message}`).join(', ');
            alert(`The selected JSON file is not a valid configuration for Solara brands. Errors: ${errorMessages}`);
        }

        return null;
    }

    async fetchBrandConfigurationsSchema() {
        const url = "https://raw.githubusercontent.com/Solara-Kit/Solara/main/solara/lib/core/doctor/schema/brand_configurations.json";

        try {
            const response = await fetch(url);
            if (!response.ok) {
                throw new Error('Network response was not ok: ' + response.statusText);
            }
            const data = await response.json();
            console.log(data);
            return data; // Return the data instead of null
        } catch (error) {
            console.error('There was a problem with the fetch operation:', error);
            return null; // Return null in case of error
        }
    }

    async createBrandConfigurationsFromDirectory(dirHandle) {
        const configList = [];
        const expectedFiles = [
            {
                key: 'theme.json',
                name: 'Theme Configuration',
                input_type: 'color'
            },
            {
                key: 'brand_config.json',
                name: 'Brand Configuration',
                input_type: 'text'
            },
            {
                key: 'android_config.json',
                name: 'Android Configuration',
                input_type: 'text'
            },
            {
                key: 'android_signing.json',
                name: 'Android Signing',
                input_type: 'text'
            },
            {
                key: 'ios_config.json',
                name: 'iOS Configuration',
                input_type: 'text'
            },
            {
                key: 'ios_signing.json',
                name: 'iOS Signing',
                input_type: 'text'
            }
        ];

        for (const file of expectedFiles) {
            try {
                const fileContent = await this.findAndReadFile(dirHandle, file.key);
                if (fileContent) {
                    configList.push({
                        key: file.key,
                        name: file.name,
                        inputType: file.input_type,
                        content: JSON.parse(fileContent)
                    });
                }
            } catch (error) {
                console.warn(`File not found or invalid JSON: ${file.key}`);
            }
        }

        return configList;
    }

    async findAndReadFile(dirHandle, filename) {
        const queue = [dirHandle];
        while (queue.length > 0) {
            const currentHandle = queue.shift();
            for await (const entry of currentHandle.values()) {
                if (entry.kind === 'file' && entry.name === filename) {
                    const file = await entry.getFile();
                    return await file.text();
                } else if (entry.kind === 'directory') {
                    queue.push(entry);
                }
            }
        }
        return null;
    }

}

export default BrandRemoteSource;