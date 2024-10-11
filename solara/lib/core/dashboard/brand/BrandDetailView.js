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

    populateJsonFields(data, container, content, inputType, level = 0) {
        container.dataset.key = data.key
        container.dataset.level = `${level}`

        for (const [key, value] of Object.entries(content)) {
            if (Array.isArray(value)) {
                this.populateJsonArray(key, value, data, container, content, inputType, level)
                continue
            }

            if (value !== null && typeof value === 'object') {
                this.populateJsonObject(key, value, data, container, content, inputType, level)
                continue
            }

            const fieldElement = this.createJsonField(data, key, value, inputType, level)
            container.appendChild(fieldElement);
        }
    }

    populateJsonArray(key, value, data, container, content, inputType, level) {
        const arrayContainer = document.createElement('div');
        arrayContainer.className = 'json-array';
        arrayContainer.classList.add(`json-array-${level}`);

        const labelContainer = document.createElement('div');
        labelContainer.className = 'json-array-label-group';
        const label = document.createElement('label');
        label.textContent = key;
        labelContainer.appendChild(label);

        // TODO: to be implemented later
        if (false) {
            const addButton = document.createElement('button');
            addButton.className = 'add-array-item';
            addButton.textContent = '+';
            let lastItemIndex = value.length - 1
            addButton.addEventListener('click', () => {
                const itemContainer = document.createElement('div');
                itemContainer.className = 'json-array-item';

                lastItemIndex += 1
                let fieldKey = `${key}[${lastItemIndex}]`

                const indexed = container.querySelectorAll(`.json-array-item-indexed-${level}`).length !== 0;
                if (indexed) {
                    fieldKey = lastItemIndex
                }
                const field = this.createJsonField(data, fieldKey, '', inputType, level + 1)
                field.classList.add(`json-array-item-${level}`);
                itemContainer.appendChild(field);

                arrayContainer.insertBefore(itemContainer, arrayContainer.lastElementChild);

                this.onSectionChanged(data, container.closest('.section'));
            });
        }
        arrayContainer.appendChild(labelContainer);

        value.forEach((item, index) => {
            const itemContainer = document.createElement('div');
            itemContainer.className = 'json-array-item';
            itemContainer.classList.add(`json-array-item-${level}`);
            if (typeof item === 'object' && item !== null) {
                this.populateJsonFields(data, itemContainer, item, inputType, level + 1);
            } else {
                itemContainer.dataset.level = `${level + 1}`
                const field = this.createJsonField(data, `${index}`, item, inputType, level + 1)
                itemContainer.classList.add(`json-array-item-indexed-${level}`);
                itemContainer.appendChild(field);
            }
            arrayContainer.appendChild(itemContainer);
        });

        // TODO: to be implemented later
        // arrayContainer.appendChild(addButton);
        container.appendChild(arrayContainer);
    }

    populateJsonObject(key, value, data, container, content, inputType, level) {
        const objectContainer = document.createElement('div');
        objectContainer.className = 'json-object';
        objectContainer.classList.add(`json-object-${level}`);
        const objectLabel = document.createElement('label');
        objectLabel.className = 'json-object-title';
        objectLabel.textContent = key;
        objectContainer.appendChild(objectLabel);

        this.populateJsonFields(data, objectContainer, value, inputType, level + 1);

        container.appendChild(objectContainer);
    }

    createJsonField(data, key, value, inputType, level) {
        const fieldInputType = typeof value === 'boolean' ? 'boolean' : inputType;
        const container = document.createElement('div');
        container.className = 'input-group';
        const label = document.createElement('label');
        label.textContent = key;
        container.appendChild(label);

        const inputWrapper = document.createElement('div');
        inputWrapper.className = 'input-wrapper';

        if (fieldInputType === 'boolean') {
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
                this.onSectionChanged(data, container.closest('.section'));
            });

            inputWrapper.appendChild(checkbox);
            inputWrapper.appendChild(checkboxLabel);
        } else {
            const input = document.createElement('input');
            input.type = fieldInputType;
            input.id = key;

            console.log(value)
            if (fieldInputType === 'color') {
                input.value = value.startsWith('#') ? value : `#${value.substring(4)}`;
            } else {
                input.value = value;
            }

            inputWrapper.appendChild(input);
        }

        const deleteIcon = document.createElement('span');
        deleteIcon.className = 'delete-icon';
        deleteIcon.textContent = '×';
        deleteIcon.onclick = () => this.onDeleteField(data, container);
        inputWrapper.appendChild(deleteIcon);

        container.appendChild(inputWrapper);

        container.addEventListener('change', () => this.onSectionChanged(data, container.closest('.section')));

        container.classList.add(`json-field-${level}`);

        return container;
    }

    showAddFieldForm(data, sectionElement, inputType) {
        this.addFieldSheet.show(inputType, (name, value) => {
            const newField = this.createJsonField(data, name, value, inputType, 0);
            sectionElement.insertBefore(newField, sectionElement.lastElementChild);
            this.onSectionChanged(data, sectionElement);
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