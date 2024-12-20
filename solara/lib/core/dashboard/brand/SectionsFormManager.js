import '../component/EditJsonSheet.js';

class SectionsFormManager {
    constructor() {
        this.sections = [];
        this.sectionsContainer = document.getElementById('sections');
    }

    display(sections, onChange) {
        this.sections = sections.map((section) => {
            return new SectionItemManager(
                section,
                this.createSection(section),
                onChange)
        })
        this.sections.forEach((item => {
            item.displayJSONCards()
        }))
    }

    createSection(section) {
        const sectionElement = document.createElement('div');
        sectionElement.className = 'section';

        sectionElement.dataset.filename = section.filename
        sectionElement.dataset.name = section.name

        const titleContainer = document.createElement('div');
        titleContainer.className = 'section-title-container';

        const title = document.createElement('h2');
        title.className = "section-title";
        title.textContent = section.name;
        titleContainer.appendChild(title);

        sectionElement.appendChild(titleContainer);

        sectionElement.id = section.filename;

        this.sectionsContainer.appendChild(sectionElement);

        return sectionElement
    }

    data() {
        const data = this.sections.map((section) => {
            return section.section
        })
        return Array.from(data);
    }
}

class SectionItemManager {
    constructor(section, container, onChange) {
        this.section = section
        this.container = container
        this.onChange = onChange
        this.editJsonSheet = document.getElementById('editJsonSheet');
    }

    displayJSONCards() {
        let cardContent = this.container.querySelector('.card-content')
        if (cardContent !== null) this.container.innerHTML = ''
        this.container.appendChild(this.createCard(this.section.content, 'root', null, this.section.filename));
    }

    createCard(obj, key, parent, cardTitle) {
        const card = document.createElement('div');
        card.className = 'card';

        const header = document.createElement('div');
        header.className = 'card-header';
        header.textContent = key === 'root' ? cardTitle : key;
        header.onclick = () => {
            if (key !== 'root') {
                this.editKey(parent, key)
                return
            }
            this.editJsonSheet.show(
                JSON.stringify(this.section.content, null, 2),
                cardTitle,
                (value) => {
                    this.section.content = value
                    this.displayJSONCards()
                    this.notifyChange()
                })
        };

        const actions = document.createElement('div');
        actions.className = 'card-actions';

        const addBtn = document.createElement('button');
        addBtn.className = 'add-property-btn';
        addBtn.innerHTML = '<i class="fas fa-plus"></i>';
        addBtn.onclick = () => this.addProperty(obj);
        actions.appendChild(addBtn);

        if (key !== 'root') {
            const deleteCardBtn = document.createElement('button');
            deleteCardBtn.className = 'delete-btn';
            deleteCardBtn.innerHTML = '<i class="fas fa-times"></i>';
            deleteCardBtn.onclick = () => this.confirmDeleteProperty(parent, key);
            actions.appendChild(deleteCardBtn);
        }

        header.appendChild(actions);
        card.appendChild(header);

        const content = document.createElement('div');
        content.className = 'card-content';

        const isArray = Array.isArray(obj)

       for (const [k, v] of Object.entries(obj)) {
            const item = document.createElement('div');

            const cardValueContainer = document.createElement('div');
            cardValueContainer.className = 'card-value-container';
            item.appendChild(cardValueContainer);

            const itemKey = document.createElement('span');
            itemKey.className = 'card-key';
            itemKey.onclick = () => {
                if (isArray) return
                this.editKey(obj, k)
            };
            cardValueContainer.appendChild(itemKey);

            if (typeof v === 'object' && v !== null) {
                item.appendChild(this.createCard(v, k, obj, null));
                itemKey.textContent = isArray ? `${key}[${k}]` : ''
            } else {
                item.className = 'card-item';
                itemKey.textContent = k.replace(/_/g, ' ')

                if (typeof v === 'boolean') {
                    // Create a container for the entire boolean input
                    const booleanContainer = document.createElement('div');
                    booleanContainer.className = 'boolean-container';

                    const checkboxContainer = document.createElement('div');
                    checkboxContainer.className = 'card-value checkbox-container';

                    const itemValue = document.createElement('input');
                    itemValue.type = 'checkbox';
                    itemValue.className = 'card-value checkbox';
                    itemValue.checked = v;

                    const valueLabel = document.createElement('span');
                    valueLabel.className = 'checkbox-value';
                    valueLabel.textContent = v.toString();

                    const updateValue = () => {
                        const newValue = !itemValue.checked;
                        itemValue.checked = newValue;
                        valueLabel.textContent = newValue.toString();
                        this.updateValue(obj, k, newValue, typeof v);
                    };

                    // Add click handlers to both container and checkbox
                    booleanContainer.onclick = (e) => {
                        if (e.target !== itemValue) { // Prevent double-toggle when clicking checkbox
                            updateValue();
                        }
                    };

                    itemValue.onchange = () => {
                        valueLabel.textContent = itemValue.checked.toString();
                        this.updateValue(obj, k, itemValue.checked, typeof v);
                    };

                    checkboxContainer.appendChild(itemValue);
                    checkboxContainer.appendChild(valueLabel);

                    // Move the key inside the boolean container
                    booleanContainer.appendChild(itemKey);
                    booleanContainer.appendChild(checkboxContainer);

                    cardValueContainer.appendChild(booleanContainer);
                } else if (this.isColorValue(v)) {
                    const itemValue = document.createElement('input');
                    itemValue.type = 'color';
                    itemValue.className = 'card-value';
                    itemValue.value = v;
                    itemValue.onchange = () => this.updateValue(obj, k, itemValue.value, typeof v);
                    cardValueContainer.appendChild(itemValue);
                } else {
                    const itemValue = document.createElement('textarea');
                    itemValue.className = 'card-value';
                    itemValue.value = v;
                    itemValue.onchange = () => this.updateValue(obj, k, itemValue.value, typeof v);
                    cardValueContainer.appendChild(itemValue);
                }

                const deleteBtn = document.createElement('button');
                deleteBtn.className = 'delete-btn';
                deleteBtn.innerHTML = '<i class="fas fa-times"></i>';
                deleteBtn.onclick = () => this.confirmDeleteProperty(obj, k);
                cardValueContainer.appendChild(deleteBtn);
            }

            content.appendChild(item);
        }

        card.appendChild(content);
        return card;
    }

    isColorValue(value) {
        const hexPattern = /^#([0-9A-F]{3}){1,2}([0-9A-F]{2})?$/i;
        const rgbaPattern = /^rgba?\(\s*(\d{1,3}\s*,\s*){2}\d{1,3}\s*,?\s*(0|1|0?\.\d+|1?\.\d+)\s*\)$/;

        return hexPattern.test(value) || rgbaPattern.test(value);
    }

    editKey(obj, oldKey) {
        const newKey = prompt('Edit property name:', oldKey);
        if (newKey && newKey !== oldKey) {
            obj[newKey] = obj[oldKey];
            delete obj[oldKey];
            this.displayJSONCards();
        }
        this.notifyChange()
    }

    updateValue(obj, key, value, originalType) {
        try {
            // Handle different types based on the original value's type
            switch (originalType) {
                case 'string':
                    obj[key] = String(value);
                    break;
                case 'number':
                    // If the original was a number, keep it number
                    if (!isNaN(value) || value === '') {
                        obj[key] = Number(value);
                    }
                    break;
                case 'boolean':
                    obj[key] = value.toLowerCase() === 'true';
                    break;
                default:
                    // Try to parse as JSON, fallback to string if it fails
                    try {
                        obj[key] = JSON.parse(value);
                    } catch {
                        obj[key] = value;
                    }
            }
        } catch {
            obj[key] = value;
        }
        this.displayJSONCards();
        this.notifyChange();
    }

    confirmDeleteProperty(obj, key) {
        const confirmationDialog = document.getElementById('confirmationDialog');
        confirmationDialog.showDialog(`Are you sure you need to delete: ${key}?`,
            async () => {
                this.deleteProperty(obj, key)
            });
    }

    deleteProperty(obj, key) {
        if (Array.isArray(obj)) {
            obj.splice(key, 1);
        } else {
            delete obj[key];
        }
        this.displayJSONCards();
        this.notifyChange()
    }

    addProperty(obj) {
        if (Array.isArray(obj)) {
            obj.push('');
        } else {
            const key = prompt('Enter new property name:');
            if (key) {
                obj[key] = '';
            }
        }
        this.displayJSONCards();
        this.notifyChange()
    }

    notifyChange() {
        this.onChange(this.section, this.container)
    }
}

export default SectionsFormManager;
