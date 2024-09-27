class BrandsModel {
    constructor() {
        this.allBrands = [];
        this.currentBrand = null;
        this.source = this.getQueryFromUrl('source') || 'remote';
    }

    getQueryFromUrl(name) {
        const urlParams = new URLSearchParams(window.location.search);
        return urlParams.get(name);
    }

    async fetchCurrentBrand() {
        try {
            const response = await fetch('/brand/current');
            let result = await response.json();
            if (!response.ok) {
                throw new Error(result.error);
            }
            this.currentBrand = result;
            return result;
        } catch (error) {
            console.error('Error fetching current brand:', error);
            return null;
        }
    }

    async fetchBrands() {
        try {
            const response = await fetch('/brands/all');
            const result = await response.json();
            if (!response.ok) {
                throw new Error(result.error);
            }
            this.allBrands = result.sort((a, b) => a.key.localeCompare(b.key));
            return this.allBrands;
        } catch (error) {
            console.error('Error fetching brands:', error);
            throw error;
        }
    }

    async fetchAliases(brand) {
        try {
            const response = await fetch(`/brand/aliases`);
            let result = await response.json();
            if (!response.ok) {
                throw new Error(result.error);
            }
            return result;
        } catch (error) {
            console.error('Error fetching aliases:', error);
            return null;
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
            return result;
        } catch (error) {
            console.error('Error switching to brand:', error);
            throw error;
        }
    }

    async onboardBrand(brandName, brandKey, cloneBrandKey = null) {
        try {
            const response = await fetch('/brand/onboard', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({brand_name: brandName, brand_key: brandKey, clone_brand_key: cloneBrandKey}),
            });
            const result = await response.json();
            if (!response.ok) {
                throw new Error(result.error);
            }
            return result;
        } catch (error) {
            console.error('Error onboarding brand:', error);
            throw error;
        }
    }

    async offboardBrand(brandKey) {
        try {
            const response = await fetch(`/brand/offboard?brand_key=${encodeURIComponent(brandKey)}`, {
                method: 'GET',
            });
            const result = await response.json();
            if (!response.ok) {
                throw new Error(result.error);
            }
            return result;
        } catch (error) {
            console.error('Error offboarding brand:', error);
            throw error;
        }
    }

    async runDoctor(brandKey) {
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

    filterBrands(searchTerm) {
        return this.allBrands.filter(brand =>
            brand.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
            brand.key.toLowerCase().includes(searchTerm.toLowerCase())
        );
    }

}

export default BrandsModel;
