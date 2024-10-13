class BrandLocalSource {
    constructor() {
        this.savingInProgress = false;
    }

    getQueryFromUrl(name) {
        const urlParams = new URLSearchParams(window.location.search);
        return urlParams.get(name);
    }

    async fetchBrandDetails(brandKey) {
        try {
            if (!brandKey) {
                throw new Error('No brand_key provided in URL');
            }

            const url = `/brand/details?brand_key=${encodeURIComponent(brandKey)}`;

            const response = await fetch(url);
            const result = await response.json();
            if (!response.ok) {
                throw new Error(result.error);
            }
            return result;
        } catch (error) {
            console.error('Error fetching configurations:', error);
            throw error;
        }
    }

    async fetchCurrentBrand(brandKey) {
        try {
            const response = await fetch('/brand/current');
            let result = await response.json();
            if (!response.ok) {
                throw new Error(result.error);
            }
            let isCurrentBrand = result.key === brandKey;
            return {isCurrentBrand: isCurrentBrand, contentChanged: result.content_changed};
        } catch (error) {
            console.error('Error fetching current brand:', error);
            throw error;
        }
    }

    async saveSection(key, configuration, brandKey) {
        if (this.savingInProgress) return;
        this.savingInProgress = true;

        const dataToSend = {
            brand_key: brandKey,
            key: key,
            data: configuration
        };

        try {
            const response = await fetch(`/section/edit`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(dataToSend)
            });

            const result = await response.json();

            if (!response.ok) {
                throw new Error(result.error);
            }

            return true;
        } catch (error) {
            console.error('Error saving configuration:', error);
            throw error;
        } finally {
            this.savingInProgress = false;
        }
    }

    async switchToBrand(brandKey) {
        try {
            const response = await fetch('/switch', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({brand_key: brandKey}),
            });

            const result = await response.json();

            if (!response.ok) {
                throw new Error(result.error);
            }

            return true;
        } catch (error) {
            console.error('Error switching to brand:', error);
            throw error;
        }
    }

    async checkBrandHealth(brandKey) {
        try {
            const response = await fetch(`/brand/doctor?brand_key=${encodeURIComponent(brandKey)}`);
            const result = await response.json();

            if (!response.ok) {
                throw new Error(result.error);
            }

            return result.result;
        } catch (error) {
            console.error('Error calling doctor API:', error);
            throw error;
        }
    }
}

export default BrandLocalSource;