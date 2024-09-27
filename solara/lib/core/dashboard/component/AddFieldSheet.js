class AddFieldSheet extends HTMLElement {
    constructor() {
        super();
        this.onSubmit = null;
        this.inputType = null;

        this.attachShadow({mode: 'open'});
        this.render();

        this.addFieldSheet = this.shadowRoot.querySelector('#addFieldSheet');
        this.overlay = this.shadowRoot.getElementById('overlay');

        this.shadowRoot.querySelector('#addFieldForm').onsubmit = (e) => this.handleSubmit(e);
        this.shadowRoot.querySelector('#colorPicker').oninput = (e) => this.updateFieldValue(e);
        this.overlay.onclick = () => this.hideAddFieldForm();
    }

    render() {
        this.shadowRoot.innerHTML = `
            <style>
    .bottom-sheet {
        position: fixed;
        bottom: -100%;
        left: 0;
        right: 0;
        background-color: white;
        padding: 21px;
        box-shadow: 0 -3.5px 14px rgba(0, 0, 0, 0.2);
        transition: bottom 0.3s ease-out;
        z-index: 1000;
        border-top-left-radius: 17.5px;
        border-top-right-radius: 17.5px;
        height: 42vh;
        max-height: 350px;
        overflow-y: auto;
        max-width: 420px;
        margin: 0 auto;
    }
    .bottom-sheet.show {
        bottom: 0;
    }
    .bottom-sheet h3 {
        color: var(--primary-color);
        margin-top: 0;
        margin-bottom: 14px;
        font-size: 16.8px;
    }
    .overlay {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.5);
        z-index: 999;
    }
    .show {
        display: block;
    }
    .form-group {
        margin-bottom: 14px;
    }
    .form-group label {
        display: block;
        margin-bottom: 5.6px;
        font-weight: bold;
        font-size: 11.2px;
    }
    .form-group input {
        width: 100%;
        padding: 8.4px;
        border: 1px solid var(--border-color);
        border-radius: 2.8px;
        font-size: 11.2px;
    }
    .add-field-button {
        width: 100%;
        padding: 10.5px;
        font-size: 12.6px;
        background-color: var(--primary-color);
        color: white;
        border: none;
        border-radius: 2.8px;
        cursor: pointer;
        transition: background-color 0.3s ease;
    }
    .add-field-button:hover {
        background-color: #3A7BC8;
    }
    .color-picker-container {
        display: none;
        margin-top: 7px;
    }
    #colorPicker {
        -webkit-appearance: none;
        border: none;
        width: 100%;
        height: 42px;
        cursor: pointer;
        border-radius: 2.8px;
    }
    #colorPicker::-webkit-color-swatch {
        border: none;
        border-radius: 2.8px;
    }
</style>

<div id="overlay" class="overlay"></div>
<div class="bottom-sheet" id="addFieldSheet">
    <h3>Add New Field</h3>
    <form id="addFieldForm">
        <div class="form-group">
            <label for="fieldName">Field Name</label>
            <input type="text" id="fieldName" name="fieldName" required>
        </div>
        <div class="form-group">
            <label for="fieldValue">Field Value</label>
            <input type="text" id="fieldValue" name="fieldValue" required>
            <div class="color-picker-container">
                <input type="color" id="colorPicker" name="colorPicker">
            </div>
        </div>
        <button type="submit" class="add-field-button">Add Field</button>
    </form>
</div>
        `;
    }

    show(inputType, onSubmit) {
        this.onSubmit = onSubmit;
        this.inputType = inputType;
        const fieldName = this.shadowRoot.querySelector('#fieldName');
        const fieldValue = this.shadowRoot.querySelector('#fieldValue');
        const colorPickerContainer = this.shadowRoot.querySelector('.color-picker-container');

        fieldName.value = '';
        fieldValue.value = '';
        colorPickerContainer.style.display = inputType === 'color' ? 'block' : 'none';

        this.addFieldSheet.style.display = 'block';
        this.overlay.classList.add('show');
        setTimeout(() => this.addFieldSheet.classList.add('show'), 10);
    }

    hideAddFieldForm() {
        this.addFieldSheet.classList.remove('show');
        this.overlay.classList.remove('show');
        setTimeout(() => {
            this.addFieldSheet.style.display = 'none';
        }, 300);
    }

    handleSubmit(e) {
        e.preventDefault();
        const fieldName = this.shadowRoot.querySelector('#fieldName').value;
        let defaultValue = this.shadowRoot.querySelector('#fieldValue').value;

        if (this.inputType === 'color' && !defaultValue.startsWith('#')) {
            defaultValue = '#' + defaultValue;
        }

        if (this.onSubmit) {
            this.onSubmit(fieldName, defaultValue);
        }
        this.hideAddFieldForm();
    }

    updateFieldValue(event) {
        const fieldValue = this.shadowRoot.querySelector('#fieldValue');
        fieldValue.value = event.target.value;
    }
}

customElements.define('add-field-sheet', AddFieldSheet);