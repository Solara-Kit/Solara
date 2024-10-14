class BrandsController {
    constructor(model, view) {
        this.model = model;
        this.view = view;
        this.view.setOnSwitch(this.switchToBrand.bind(this));
    }

    async init() {
        await this.model.fetchCurrentBrand();
        await this.renderBrands();
        await this.checkBrandsHealth();
        this.attachEventListeners();
    }

    async renderBrands() {
        const brands = await this.model.fetchBrands();
        this.view.renderBrands(brands, this.model.currentBrand);
    }

    attachEventListeners() {
        document.querySelector('.onboard-brand-button')
            .addEventListener('click', () => this.showOnboardBrandForm());
        document.getElementById('brandSearch')
            .addEventListener('input', (e) => this.filterBrands(e.target.value));

        this.view.brandOptionsSheet.addEventListener('clone', (event) => {
            this.handleCloneOption(event)
        });

        this.view.brandOptionsSheet.addEventListener('offboard', (event) => {
            this.handleOffboardOption(event)
        });

        this.view.brandOptionsSheet.addEventListener('doctor', (event) => {
            this.handleDoctorOption(event)
        });

        this.view.brandOptionsSheet.addEventListener('aliases', (event) => {
            this.handleAliasesOption(event)
        });

        this.view.brandOptionsSheet.addEventListener('settings', (event) => {
            this.handleSettingsOption(event)
        });
    }

    showOnboardBrandForm(clone_brand_key = null) {
        this.view.showOnboardBrandForm();
        this.view.onboardSheet.addEventListener('onboard', async (event) => {
            event.preventDefault();
            const {brandKey, brandName} = event.detail;
            await this.handleOnboardBrandSubmit(brandKey, brandName, clone_brand_key);
        });
    }

    async handleOnboardBrandSubmit(brandKey, brandName, clone_brand_key = null) {
        try {
            await this.model.onboardBrand(brandName, brandKey, clone_brand_key);
            await this.view.hideOnboardBrandForm();
            location.reload();
        } catch (error) {
            console.error('Error during submission:', error);
            alert(error);
        }
    }

    filterBrands(searchTerm) {
        const filteredBrands = this.model.filterBrands(searchTerm);
        this.view.renderBrands(filteredBrands, this.model.currentBrand);
    }

    async checkBrandsHealth() {
        const result = await this.model.runDoctor("");
        const errorButton = document.getElementById('error-button');

        if (!result.passed) {
            this.view.showErrorButton();
            this.view.updateErrorCount(result.errors.length);

            errorButton.addEventListener('click', () => {
                const errors = result.errors
                    .map((error, index) => `${index + 1}. ${error}`)
                    .join('\n');
                this.view.showMessage(`Health check for all brands completed with errors: \n\n${errors}`);
            });
        } else {
            this.view.hideErrorButton();
        }
    }

    handleCloneOption(event) {
        event.stopPropagation();
        const brandKey = this.view.brandOptionsSheet.dataset.brandKey;
        this.showOnboardBrandForm(brandKey);
    }

    handleOffboardOption(event) {
        event.stopPropagation();
        const brandKey = this.view.brandOptionsSheet.dataset.brandKey;
        const brandName = this.view.brandOptionsSheet.dataset.brandName;
        this.view.showConfirmationDialog(`Are you sure you need to offboard ${brandKey} (${brandName}) and delete all its configurations?`,
            async () => {
                await this.model.offboardBrand(brandKey);
                location.reload();
            });
    }

    async handleDoctorOption(event) {
        event.stopPropagation();

        const brandKey = this.view.brandOptionsSheet.dataset.brandKey;
        const result = await this.model.runDoctor(brandKey);
        if (!result.passed) {
            const errors = result.errors
                .map((error, index) => `${index + 1}. ${error}`)
                .join('\n');
            this.view.showMessage(`Health check for ${brandKey} completed with errors:\n${errors}`);
        } else {
            this.view.showMessage(`Health check for ${brandKey}. All systems operational.`);
        }
    }

    async handleAliasesOption(event) {
        event.stopPropagation();

        const brandKey = this.view.brandOptionsSheet.dataset.brandKey;
        const aliases = await this.model.fetchAliases(brandKey);
        if (aliases) {
            this.view.showAliasesBottomSheet(aliases, brandKey);
        }
    }

    handleSettingsOption(event) {
        event.stopPropagation();

        const brandKey = this.view.brandOptionsSheet.dataset.brandKey;
        window.location.href = this.view.brandUrl(brandKey);
    }

    async switchToBrand(brandKey) {
        try {
            await this.model.switchToBrand(brandKey);
            location.reload();
        } catch (error) {
            console.error('Error switching to brand:', error);
            alert(error.message);
        }
    }
}

export default BrandsController;