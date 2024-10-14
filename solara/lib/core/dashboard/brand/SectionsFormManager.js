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

        sectionElement.dataset.key = section.key
        sectionElement.dataset.name = section.name
        sectionElement.dataset.inputType = section.inputType

        const titleContainer = document.createElement('div');
        titleContainer.className = 'section-title-container';

        const title = document.createElement('h2');
        title.textContent = section.name;
        titleContainer.appendChild(title);

        sectionElement.appendChild(titleContainer);

        sectionElement.id = section.key;

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
        this.container.appendChild(this.createCard(this.section.content, 'root', null, this.section.key));
    }

    createCard(obj, key, parent, cardTitle) {
        const card = document.createElement('div');
        card.className = 'card';

        const header = document.createElement('div');
        header.className = 'card-header';
        header.textContent = key === 'root' ? cardTitle : key;
        if (key === 'root') {
            header.onclick = () => {
                this.editJsonSheet.show(
                    JSON.stringify(this.section.content, null, 2),
                    key,
                    (value) => {
                        this.section.content = value
                        this.displayJSONCards()
                        this.notifyChange()
                    })
            };
        }

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
            deleteCardBtn.onclick = () => this.deleteProperty(parent, key);
            actions.appendChild(deleteCardBtn);
        }

        header.appendChild(actions);
        card.appendChild(header);

        const content = document.createElement('div');
        content.className = 'card-content';

        const isArray = Array.isArray(obj)

        for (const [k, v] of Object.entries(obj)) {
            const item = document.createElement('div');
            item.className = 'card-item';

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
                itemKey.textContent = k.replace(/_/g, ' ')

                if (this.isColorValue(v)) {
                    const itemValue = document.createElement('input');
                    itemValue.type = 'color';
                    itemValue.className = 'card-value color-picker';
                    itemValue.value = v;
                    itemValue.onchange = () => this.updateValue(obj, k, itemValue.value);
                    cardValueContainer.appendChild(itemValue);
                } else {
                    const itemValue = document.createElement('textarea');
                    itemValue.className = 'card-value';
                    itemValue.value = v;
                    itemValue.onchange = () => this.updateValue(obj, k, itemValue.value);
                    cardValueContainer.appendChild(itemValue);
                }

                const deleteBtn = document.createElement('button');
                deleteBtn.className = 'delete-btn';
                deleteBtn.innerHTML = '<i class="fas fa-times"></i>';
                deleteBtn.onclick = () => this.deleteProperty(obj, k);
                cardValueContainer.appendChild(deleteBtn);
            }

            content.appendChild(item);
        }

        card.appendChild(content);
        return card;
    }

    isColorValue(value) {
        // Check if the value is a valid color
        return /^#([0-9A-F]{3}){1,2}$/i.test(value);
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

    updateValue(obj, key, value) {
        try {
            obj[key] = JSON.parse(value);
        } catch {
            obj[key] = value;
        }
        this.displayJSONCards();
        this.notifyChange()
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