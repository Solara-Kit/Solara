import {DataSource} from './BrandDetailModel.js';
import '../component/OnboardBrandBottomSheet.js';
import '../component/AddFieldSheet.js';
import '../component/ConfirmationDialog.js';
import '../component/MessageBottomSheet.js';

class BrandDetailView {
    constructor(model) {
        this.model = model;

        this.header = document.getElementById('header');

        this.brandDetailsContainer = document.getElementById('brand-details-container');
        this.addBrandOverlay = document.getElementById('add-brand-overlay');
        this.addBrandContainer = document.getElementById('add-brand-container');

        this.sectionsContainer = document.getElementById('sections');
        this.addFieldSheet = document.getElementById('addFieldSheet');
        this.confirmationDialog = document.getElementById('confirmationDialog');
        this.messageBottomSheet = document.getElementById('messageBottomSheet');

        this.uploadBrandBtn = document.getElementById('uploadBrandBtn');
        this.uploadJsonBtn = document.getElementById('uploadJsonBtn');
        this.addNewBrandBtn = document.getElementById('newBrandBtn');
        this.exportBrandBtn = document.getElementById('exportBrandBtn');
        this.allBrandsButton = document.getElementById('allBrandsButton');

        this.onboardSheet = document.getElementById('onboardBottomSheet');

        this.initializeApp();
    }

    async initializeApp() {
        switch (this.model.source) {
            case DataSource.LOCAL:
                return await this.setupLocal();
            case DataSource.REMOTE:
                return await this.setupRemote();
            default:
                throw new Error('Unknown data source');
        }
    }

    async setupLocal() {
        this.addBrandOverlay.style.display = 'none'
        this.header.style.display = 'flex'
        this.allBrandsButton.style.display = 'block'
        this.toggleAddBrandContainer(false);
    }

    async setupRemote() {
        this.addBrandOverlay.style.display = 'flex'
        this.header.style.display = 'none'
        this.allBrandsButton.style.display = 'none'
        this.toggleAddBrandContainer(true);
    }

    toggleAddBrandContainer(show) {
        this.addBrandContainer.style.display = show ? 'block' : 'none';
        this.brandDetailsContainer.style.display = show ? 'none' : 'block';
    }

    updateAppNameTitle(brandName) {
        const brandNametitle = document.getElementById('brandNametitle');
        if (brandNametitle) {
            brandNametitle.textContent = brandName;
        }
    }

    createSection(key, name, inputType) {
        const section = document.createElement('div');
        section.className = 'section';

        section.dataset.key = key
        section.dataset.name = name
        section.dataset.inputType = inputType

        const titleContainer = document.createElement('div');
        titleContainer.className = 'section-title-container';

        const title = document.createElement('h2');
        title.textContent = name;
        titleContainer.appendChild(title);

        const subtitleElement = document.createElement('p');
        subtitleElement.className = 'section-subtitle';
        subtitleElement.textContent = key;
        titleContainer.appendChild(subtitleElement);

        section.appendChild(titleContainer);

        return section;
    }

    populateSection(sectionItem, sectionElement, content, inputType) {
        for (const [key, value] of Object.entries(content)) {
            if (Array.isArray(value)) {
                sectionElement.appendChild(this.createInputField(sectionItem, key, value, 'array'));
            } else if (typeof value === 'object' && value !== null) {
                for (const [subKey, subValue] of Object.entries(value)) {
                    const subInputType = subValue === true || subValue === false ? 'boolean' : inputType;
                    sectionElement.appendChild(this.createInputField(sectionItem, `${key}.${subKey}`, subValue, subInputType));
                }
            } else {
                const fieldInputType = value === true || value === false ? 'boolean' : inputType;
                sectionElement.appendChild(this.createInputField(sectionItem, key, value, fieldInputType));
            }
        }
    }

    createInputField(sectionItem, key, value, inputType) {
        const container = document.createElement('div');
        container.className = 'input-group';
        const label = document.createElement('label');
        label.textContent = key;
        container.appendChild(label);

        const inputWrapper = document.createElement('div');
        inputWrapper.className = 'input-wrapper';

        if (inputType === 'array') {
            const arrayInputContainer = document.createElement('div');
            arrayInputContainer.className = 'array-input-container';

            const input = document.createElement('input');
            input.type = 'text';
            input.id = key;
            input.className = 'array-input';
            input.placeholder = 'Enter array value';

            const addButton = document.createElement('button');
            addButton.className = 'add-array-item';
            addButton.textContent = '+';

            arrayInputContainer.appendChild(input);
            arrayInputContainer.appendChild(addButton);

            const arrayItemsContainer = document.createElement('div');
            arrayItemsContainer.className = 'array-items-container';

            inputWrapper.appendChild(arrayInputContainer);
            inputWrapper.appendChild(arrayItemsContainer);

            if (Array.isArray(value)) {
                value.forEach(item => {
                    this.addArrayItem(sectionItem, arrayItemsContainer, item);
                });
            }

            addButton.addEventListener('click', () => {
                this.addArrayItem(sectionItem, arrayItemsContainer, input.value.trim());
                input.value = '';
            });

        } else if (inputType === 'boolean') {
            const checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.id = key;
            checkbox.checked = value;

            const checkboxLabel = document.createElement('label');
            checkboxLabel.className = 'checkbox-label';
            checkboxLabel.htmlFor = key;
            checkboxLabel.textContent = value ? 'True' : 'False';

            checkbox.addEventListener('change', () => {
                checkboxLabel.textContent = checkbox.checked ? 'True' : 'False';
                this.onSectionChanged(sectionItem, container.closest('.section'));
            });

            inputWrapper.appendChild(checkbox);
            inputWrapper.appendChild(checkboxLabel);
        } else {
            const input = document.createElement('input');
            input.type = inputType;
            input.id = key;

            console.log(value)
            if (inputType === 'color') {
                input.value = value.startsWith('#') ? value : `#${value.substring(4)}`;
            } else {
                input.value = value;
            }

            inputWrapper.appendChild(input);
        }

        const deleteIcon = document.createElement('span');
        deleteIcon.className = 'delete-icon';
        deleteIcon.textContent = '×';
        deleteIcon.onclick = () => this.onDeleteField(sectionItem, container);
        inputWrapper.appendChild(deleteIcon);

        container.appendChild(inputWrapper);

        container.addEventListener('change', () => this.onSectionChanged(sectionItem, container.closest('.section')));

        return container;
    }

    addArrayItem(sectionItem, container, value) {
        const itemContainer = document.createElement('div');
        itemContainer.classList.add('array-item');

        const itemInput = document.createElement('input');
        itemInput.type = 'text';
        itemInput.classList.add('array-item-input');
        itemInput.value = value;

        const deleteButton = document.createElement('button');
        deleteButton.classList.add('delete-array-item');
        deleteButton.textContent = '×';
        deleteButton.addEventListener('click', () => {
            itemContainer.remove();
            this.onSectionChanged(sectionItem, container.closest('.section'));
        });

        itemContainer.appendChild(itemInput);
        itemContainer.appendChild(deleteButton);
        container.appendChild(itemContainer);

        this.onSectionChanged(sectionItem, container.closest('.section'));
    }

    showAddFieldForm(sectionItem, sectionElement, inputType) {
        this.addFieldSheet.show(inputType, (name, value) => {
            const newField = this.createInputField(sectionItem, name, value, inputType);
            sectionElement.insertBefore(newField, sectionElement.lastElementChild);
            this.onSectionChanged(sectionItem, sectionElement);
        })
    }

    showConfirmationDialog(message, onConfirm) {
        this.confirmationDialog.showDialog(message, onConfirm);
    }

    showApplyChangesButton() {
        const applyChangesButton = document.getElementById('applyChangesButton');
        applyChangesButton.style.display = 'block';
        this.header.style.backgroundColor = '#ff4136';
    }

    showSwitchButton() {
        const switchButton = document.getElementById('switchButton');
        switchButton.style.display = 'block';
    }

    updateErrorCount(count) {
        const countElement = document.querySelector('.count');
        countElement.textContent = count;
    }

    showMessage(message) {
        this.messageBottomSheet.showMessage(message);
    }

    setOnSectionChangedHandler(handler) {
        this.onSectionChanged = handler;
    }

    setOnDeleteFieldHandler(handler) {
        this.onDeleteField = handler;
    }

    showOnboardBrandForm(onSubmit) {
        this.onboardSheet.show('Brand Details', 'Add Brand', onSubmit);
    }

    showIndex() {
        const sectionsContainer = this.sectionsContainer;
        const sectionElements = Array.from(sectionsContainer.querySelectorAll('.section'));

        const indexElement = document.getElementById('index');

        // Clear existing items if needed
        indexElement.innerHTML = '';

        sectionElements.forEach(sectionElement => {
            const newItem = document.createElement('li');
            newItem.classList.add('index-item');
            newItem.innerHTML = `<a href="#${sectionElement.id}">${sectionElement.dataset.name}</a>`;
            indexElement.appendChild(newItem);
        });
    }

    async hideOnboardBrandForm() {
        this.onboardSheet.hide();
    }

}

export default BrandDetailView;