import BrandLocalSource from './source/BrandLocalSource.js';
import BrandRemoteSource from './source/BrandRemoteSource.js';

export const DataSource = {
    LOCAL: 'local',
    REMOTE: 'remote',
};

class BrandDetailModel {
    constructor() {
        this.localSource = new BrandLocalSource();
        this.remoteSource = new BrandRemoteSource();

        this.brandKey = this.getQueryFromUrl('brand_key');

        const sourceFromUrl = this.getQueryFromUrl('source');
        this.source = sourceFromUrl === DataSource.LOCAL ? DataSource.LOCAL : DataSource.REMOTE;
    }

    getQueryFromUrl(name) {
        return this.localSource.getQueryFromUrl(name);
    }

    async fetchBrandDetails() {
        return await this.localSource.fetchBrandDetails(this.brandKey);
    }

    async fetchCurrentBrand() {
        return await this.localSource.fetchCurrentBrand(this.brandKey);
    }

    async saveSection(sectionItem, configuration) {
        switch (this.source) {
            case DataSource.LOCAL:
                return await this.localSource.saveSection(sectionItem, configuration, this.brandKey);
            case DataSource.REMOTE:
                // Saving is not supported remotely. Instead, user can export the brand.
                return
            default:
                throw new Error('Unknown data source');
        }
    }

    async switchToBrand() {
        return await this.localSource.switchToBrand(this.brandKey);
    }

    async checkBrandHealth() {
        switch (this.source) {
            case DataSource.LOCAL:
        return await this.localSource.checkBrandHealth(this.brandKey);
            case DataSource.REMOTE:
                // Checking health is not supported remotely yet.
                return
            default:
                throw new Error('Unknown data source');
        }
    }

    async createNewBrandConfogurations() {
        return await this.remoteSource.createNewBrandConfogurations();
    }

    async createBrandConfigurationsFromDirectory(dirHandle) {
        return await this.remoteSource.createBrandConfigurationsFromDirectory(dirHandle);
    }

    async getBrandConfigurationsJsonFromDirectory(dirHandle) {
        return await this.remoteSource.getBrandConfigurationsJsonFromDirectory(dirHandle);
    }

    async fetchSolaraVersion() {
        const versionUrl = 'https://raw.githubusercontent.com/Solara-Kit/Solara/main/solara/lib/solara/version.rb';

        try {
            const response = await fetch(versionUrl);

            if (!response.ok) {
                throw new Error('Network response was not okay');
            }

            const data = await response.text();
            // Assuming the version is in a line like `VERSION = "x.y.z"`
            const versionMatch = data.match(/VERSION\s*=\s*["']([^"']+)["']/);

            if (versionMatch) {
                return versionMatch[1]; // Return the version
            } else {
                throw new Error('VERSION not found');
            }

        } catch (error) {
            console.error('There was a problem with the fetch operation:', error);
            return null; // Return null or handle the error as needed
        }
    }

    async createBrandDetail(key, name, configurations) {
        const solaraVersion = await this.fetchSolaraVersion()
        return {
            solaraVersion: solaraVersion,
            brand: {key: key, name: name},
            configurations: configurations
        };
    }

    async exportBrand(key, name, configurations) {
        try {
            const data = await this.createBrandDetail(key, name, configurations)

            const json = JSON.stringify(data, null, 2); // Pretty-printing JSON

            // Create a Blob from the JSON string
            const blob = new Blob([json], {type: 'application/json'});
            const url = URL.createObjectURL(blob);

            // Create a link element to download the Blob
            const a = document.createElement('a');
            a.href = url;
            a.download = `${key}-solara-configurations.json`; // Set the filename
            document.body.appendChild(a);
            a.click(); // Programmatically click the link to trigger the download
            document.body.removeChild(a); // Clean up the DOM

            // Revoke the object URL after the download
            URL.revokeObjectURL(url);
        } catch (error) {
            console.error('Error downloading brand:', error);
            alert(error.message);
        }
    }
}

export default BrandDetailModel;
