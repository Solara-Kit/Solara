import {DataSource} from './BrandDetailModel.js';

class BrandDetailController {
    constructor(model, view) {
        this.model = model;
        this.view = view;
        this.initializeEventListeners();
    }

    async initializeApp() {
        switch (this.model.source) {
            case DataSource.LOCAL:
                return await this.setupLoal();
            case DataSource.REMOTE:
                return await this.setupRemote();
            default:
                throw new Error('Unknown data source');
        }
    }

    async setupRemote() {
        this.view.uploadJsonBtn.addEventListener('click', async () => {
            await this.uploadJson()
        });

        this.view.uploadBrandBtn.addEventListener('click', async () => {
            await this.uploadBrand()
        });
        this.view.addNewBrandBtn.addEventListener('click', async () => {
            await this.addNewBrand()
        });
    }

    async uploadJson() {
        try {
            const [fileHandle] = await window.showOpenFilePicker({
                types: [{
                    description: 'JSON File',
                    accept: {
                        'application/json': ['.json'],
                    },
                }],
            });

            const file = await fileHandle.getFile();

            const json = await this.model.getBrandConfigurationsJsonFromDirectory(file);

            if (!json) {
                return
            }
            await this.addBrand(json.brand.key, json.brand.name, json.configurations)
        } catch (error) {
            console.error('Error:', error);
        }
    }

    async uploadBrand() {
        try {
            const dirHandle = await window.showDirectoryPicker();
            const configurations = await this.model.createBrandConfigurationsFromDirectory(dirHandle);

            if (configurations.length === 0) {
                alert("Please choose the appropriate brand folder that includes the brand JSON files.")
                return
            }

            this.view.showOnboardBrandForm((key, name) => {
                this.addBrand(key, name, configurations)
            })
        } catch (error) {
            console.error('Error:', error);
        }
    }

    async addNewBrand() {
        this.view.showOnboardBrandForm(async (key, name) => {
            const configurations = await this.model.createNewBrandConfogurations()
            await this.addBrand(key, name, configurations)
        })
    }

    async addBrand(key, name, configurations) {
        const result = await this.model.createBrandDetail(key, name, configurations)
        await this.onLoadSections(result)
        this.view.toggleAddBrandContainer(false);
    }

    async setupLoal() {
        try {
            const response = await this.model.fetchBrandDetails();
            await this.onLoadSections(response.result);
            const {isCurrentBrand, contentChanged} = await this.model.fetchCurrentBrand();

            if (!isCurrentBrand) {
                this.view.showSwitchButton();
            } else if (contentChanged) {
                this.view.showApplyChangesButton();
            }

            await this.checkBrandHealth();
        } catch (error) {
            console.error('Error initializing app:', error);
            alert(error.message);
        }
    }

    async onLoadSections(configuraationsResult) {
        try {
            this.view.addBrandOverlay.style.display = 'none'
            this.view.header.style.display = 'flex';
            this.view.updateAppNameTitle(`${configuraationsResult.brand.key} (${configuraationsResult.brand.name})`);
            await this.showSections(configuraationsResult);
            this.view.showIndex();
        } catch (error) {
            console.error('Error initializing app:', error);
            alert(error.message);
        }
    }

    initializeEventListeners() {
        this.view.allBrandsButton.addEventListener('click', () => {
            window.location.href = `../brands/brands.html?source=${this.model.source}`;
        });

        document.getElementById('applyChangesButton').addEventListener('click', () => this.switchToBrand());
        document.getElementById('switchButton').addEventListener('click', () => this.switchToBrand());

        this.view.exportBrandBtn.addEventListener('click', () => this.exportBrand());
    }

    async showSections(configuraationsResult) {
        try {
            this.view.sectionsContainer.dataset.brandName = configuraationsResult.brand.name
            this.view.sectionsContainer.dataset.brandKey = configuraationsResult.brand.key

            const sectionItems = configuraationsResult.configurations

            this.view.sectionsFormManager.display(
                sectionItems,
                (section, container) => {
                    this.onSectionChanged(section, container)
                })

        } catch (error) {
            console.error('Error loading configurations:', error);
            alert(error.message);
        }
    }

    async onSectionChanged(section, container) {
        try {
            await this.model.saveSection(container.dataset.key, section.content);
            this.view.showApplyChangesButton();
            await this.checkBrandHealth();
        } catch (error) {
            console.error('Error saving section:', error);
            alert(error.message);
        }
    }

    async switchToBrand() {
        try {
            await this.model.switchToBrand();
            const applyChangesButton = document.getElementById('applyChangesButton');
            applyChangesButton.style.display = 'none';
            location.reload();
        } catch (error) {
            console.error('Error switching to brand:', error);
            alert(error.message);
        }
    }

    async checkBrandHealth() {
        try {
            const result = await this.model.checkBrandHealth();
            const errorButton = document.getElementById('error-button');

            if (!result.passed) {
                errorButton.style.display = "flex";
                const errors = result.errors
                    .map((error, index) => `${index + 1}. ${error}`)
                    .join('\n');
                this.view.updateErrorCount(result.errors.length);

                errorButton.onclick = () => {
                    this.view.showMessage(`Health check for all brands completed with errors: \n\n${errors}`);
                };
            } else {
                errorButton.style.display = "none";
            }
        } catch (error) {
            console.error('Error checking brand health:', error);
            alert(error.message);
        }
    }

    async exportBrand() {
        try {
            const result = this.view.sectionsFormManager.data();

            const brandKey = this.view.sectionsContainer.dataset.brandKey;
            const brandName = this.view.sectionsContainer.dataset.brandName;

            this.model.exportBrand(brandKey, brandName, result);

        } catch (error) {
            console.error('Error downloading brand:', error);
            alert(error.message);
        }
    }

}


export default BrandDetailController;