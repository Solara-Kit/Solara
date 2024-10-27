import Ajv from 'https://cdn.skypack.dev/ajv@8.11.0';

class BrandRemoteSource {
    constructor() {
    }

    async createNewBrandConfigurations() {
        const url = 'https://raw.githubusercontent.com/Solara-Kit/Solara/refs/heads/develop/solara/lib/core/template/configurations.json';

        try {
            const response = await fetch(url);
            if (!response.ok) {
                throw new Error('Network response was not ok: ' + response.statusText);
            }

            const configurations = await response.json();
            const contentPromises = configurations.configurations.map(async (config) => {
                const contentResponse = await fetch(config.url);
                if (!contentResponse.ok) {
                    throw new Error('Failed to fetch content for ' + config.key);
                }
                const content = await contentResponse.json();
                return {
                    filename: config.filename,
                    name: this.snakeToCapitalizedSpaced(config.filename, 'ios'),
                    content: content
                };
            });

            // Wait for all content fetch promises to resolve
            return await Promise.all(contentPromises);

        } catch (error) {
            console.error('There was a problem with the fetch operation:', error);
            return null; // Return null in case of error
        }
    }

    // TODO: should be ecnapsulated
    snakeToCapitalizedSpaced(
        snakeCaseString,
        exclude = '',
        transform = (item) => item.charAt(0).toUpperCase() + item.slice(1)
    ) {
        // Split by underscores
        const parts = snakeCaseString.split('_').map(item => {
            // Return the item as-is if it matches the exclude value
            return item === exclude ? item : transform(item);
        });

        // Join the parts with a space
        return parts.join(' ');
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
            return await response.json();
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
                name: 'Theme Configuration'
            },
            {
                key: 'brand_config.json',
                name: 'Brand Configuration'
            },
            {
                key: 'android_config.json',
                name: 'Android Configuration'
            },
            {
                key: 'android_signing.json',
                name: 'Android Signing'
            },
            {
                key: 'ios_config.json',
                name: 'iOS Configuration'
            },
            {
                key: 'ios_signing.json',
                name: 'iOS Signing'
            }
        ];

        for (const file of expectedFiles) {
            try {
                const fileContent = await this.findAndReadFile(dirHandle, file.key);
                if (fileContent) {
                    configList.push({
                        key: file.key,
                        name: file.name,
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