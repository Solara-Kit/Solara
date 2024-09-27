import {DataSource} from './BrandDetailModel.js';
import InfoPlistStringCatalogManager from "./InfoPlistStringCatalogManager.js";

class BrandDetailController {
    constructor(model, view) {
        this.model = model;
        this.view = view;
        this.onSectionChanged = this.onSectionChanged.bind(this);
        this.deleteField = this.deleteField.bind(this);
        this.initializeEventListeners();
        this.view.setOnSectionChangedHandler(this.onSectionChanged.bind(this));
        this.view.setOnDeleteFieldHandler(this.deleteField.bind(this));
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
            console.log(configurations)
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

            for (let i = 0; i < sectionItems.length; i++) {
                const sectionInfo = sectionItems[i];
                console.log('Processing section:', i, sectionInfo);

                if (sectionInfo.key === 'theme.json') {
                    this.createThemeSections(sectionInfo)
                } else if (sectionInfo.key === 'InfoPlist.xcstrings') {
                    this.createSection(
                        sectionInfo.key,
                        sectionInfo,
                        new InfoPlistStringCatalogManager(sectionInfo.content).extractLocalizations(),
                        sectionInfo.name,
                        sectionInfo.inputType)
                } else {
                    this.createSection(sectionInfo.key, sectionInfo, sectionInfo.content, sectionInfo.name, sectionInfo.inputType)
                }
            }
        } catch (error) {
            console.error('Error loading configurations:', error);
            alert(error.message);
        }
    }

    createThemeSections(sectionInfo) {
        this.createSection(`${sectionInfo.key}_colors`,
            sectionInfo,
            sectionInfo.content.colors,
            'Theme Colors',
            'color',
            'colors')
        this.createSection(`${sectionInfo.key}_typography`,
            sectionInfo,
            sectionInfo.content.typography,
            'Theme Typography',
            'text',
            'typography')
        this.createSection(`${sectionInfo.key}_spacing`,
            sectionInfo,
            sectionInfo.content.spacing,
            'Theme Spacing', 'text',
            'spacing')
        this.createSection(
            `${sectionInfo.key}_borderRadius`,
            sectionInfo,
            sectionInfo.content.borderRadius,
            'Theme Border Radius',
            'text',
            'borderRadius')
        this.createSection(
            `${sectionInfo.key}_elevation`,
            sectionInfo,
            sectionInfo.content.elevation,
            'Theme Elevation',
            'text',
            'elevation')
    }

    createSection(id, sectionInfo, content, sectionName, inputType, propertiesGroupName = null) {
        const sectionElement = this.view.createSection(sectionInfo.key, sectionName, inputType);
        sectionElement.id = id;
        sectionElement.dataset.propertiesGroupName = propertiesGroupName

        this.view.sectionsContainer.appendChild(sectionElement);

        console.log('Section element created:', sectionElement);

        this.view.populateSection(sectionInfo, sectionElement, content, inputType);

        const addButton = document.createElement('button');
        addButton.textContent = 'Add Field';
        addButton.className = 'add-field-btn';
        addButton.onclick = () => this.addNewField(sectionInfo, sectionElement, inputType);
        sectionElement.appendChild(addButton);
    }

    async onSectionChanged(sectionItem, sectionElement) {
        try {
            const configuration = await this.getSectionData(sectionElement.dataset.key)
            await this.model.saveSection(sectionItem, configuration);
            this.view.showApplyChangesButton();
            await this.checkBrandHealth();
        } catch (error) {
            console.error('Error saving section:', error);
            alert(error.message);
        }
    }

    getSectionConfiguration(sectionElement) {
        const configuration = {};
        const inputs = sectionElement.querySelectorAll('input:not(.array-item-input)');
        inputs.forEach(input => {
            const keys = input.id.split('.');
            let current = configuration;
            for (let i = 0; i < keys.length - 1; i++) {
                if (!current[keys[i]]) {
                    current[keys[i]] = {};
                }
                current = current[keys[i]];
            }
            const lastKey = keys[keys.length - 1];

            if (input.classList.contains('array-input')) {
                const arrayItemsContainer = input.closest('.input-wrapper').querySelector('.array-items-container');
                current[lastKey] = this.getArrayValue(arrayItemsContainer);
            } else if (input.type === 'checkbox') {
                current[lastKey] = input.checked;
            } else {
                let value = input.value;
                if (input.type === 'color') {
                    value = `#${value.substring(1).toUpperCase()}`;
                } else if (!isNaN(value) && value.trim() !== '') {
                    // Convert to number if it's a valid number string
                    value = parseFloat(value);
                }
                current[lastKey] = value;
            }
        });
        return configuration;
    }

    addNewField(sectionItem, sectionElement, inputType) {
        this.view.showAddFieldForm(sectionItem, sectionElement, inputType);
    }

    deleteField(sectionItem, fieldContainer) {
        this.view.showConfirmationDialog(
            'Are you sure you want to delete this item?',
            () => {
                const sectionElement = fieldContainer.closest('.section');
                fieldContainer.remove();
                this.onSectionChanged(sectionItem, sectionElement);
            }
        );
    }

    getArrayValue(container) {
        const arrayItems = container.querySelectorAll('.array-item-input');
        return Array.from(arrayItems).map(item => item.value);
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

    async getSectionData(sectionKey) {
        try {
            const container = this.view.sectionsContainer;

            const sectionElements = Array.from(container.querySelectorAll('.section'))
                .filter(element => element.dataset.key === sectionKey);

            if (sectionElements.length === 1) {
                return this.getSectionConfiguration(sectionElements[0])
            }

            const configurations = sectionElements.map(sectionElement => {
                const propertiesGroupName = sectionElement.dataset.propertiesGroupName;
                const config = this.getSectionConfiguration(sectionElement);

                if (propertiesGroupName !== "null") {
                    return {[propertiesGroupName]: config};
                } else {
                    return config;
                }
            });

            const result = configurations.reduce((acc, config) => {
                const key = Object.keys(config)[0]; // Get the key from the configuration item
                acc[key] = config[key]; // Assign the value to the dynamic object
                return acc;
            }, {});

            const json = JSON.stringify(result, null, 2); // Pretty-printing JSON
            console.log(json);
            return result;

        } catch (error) {
            console.error('Error downloading brand:', error);
            alert(error.message);
        }
    }

    async exportBrand() {
        try {
            const sectionsContainer = this.view.sectionsContainer;

            const brandKey = this.view.sectionsContainer.dataset.brandKey;
            const brandName = this.view.sectionsContainer.dataset.brandName;

            const sectionElements = Array.from(sectionsContainer.querySelectorAll('.section'));

            const uniqueSections = new Map();

            // The theme section has been divided into multiple categories (e.g., colors, typography).
            // In the getSectionData function, we merge these sections. To prevent duplication when
            // processing the sections, we will ensure that each section key is processed only once.
            await Promise.all(sectionElements.map(async sectionElement => {
                const key = sectionElement.dataset.key;
                // Check if the key already exists in the map
                if (!uniqueSections.has(key)) {
                    const configurations = await this.getSectionData(key);
                    uniqueSections.set(
                        key, {
                            key: key,
                            name: sectionElement.dataset.name,
                            inputType: sectionElement.dataset.inputType,
                            content: configurations
                        });
                }
            }));

            // Convert the map values to an array
            const result = Array.from(uniqueSections.values());

            this.model.exportBrand(brandKey, brandName, result);

        } catch (error) {
            console.error('Error downloading brand:', error);
            alert(error.message);
        }
    }

}



export default BrandDetailController;