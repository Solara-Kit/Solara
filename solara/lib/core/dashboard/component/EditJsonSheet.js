class EditJsonSheet extends HTMLElement {
    constructor() {
        super();
        this.onSubmit = null;
        this.attachShadow({mode: 'open'});
        this.render();

        this.sheet = this.shadowRoot.querySelector('#sheet');
        this.overlay = this.shadowRoot.getElementById('overlay');
        this.titleText = this.shadowRoot.getElementById('title');
        this.valueInput = this.shadowRoot.querySelector('#valueInput');

        this.shadowRoot.querySelector('#editJsonSheet').onsubmit = (e) => this.handleSubmit(e);
        this.overlay.onclick = () => this.hideSheet();
    }

    render() {
        this.shadowRoot.innerHTML = `
<style>
    .bottom-sheet {
        display: flex;
        flex-direction: column; /* Stack children vertically */
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
        height: 70vh; /* Height set to 70% of viewport height */
        overflow-y: auto; /* Enable scrolling if content overflows */
        max-width: 60%;
        margin: 0 auto;
        align-items: stretch; /* Allow children to stretch */
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
        max-width: 98%;
        margin-bottom: 14px;
        flex-grow: 1; /* Allow form group to grow */
    }
    .form-group label {
        display: block;
        margin-bottom: 5.6px;
        font-weight: bold;
        font-size: 11.2px;
    }
    .form-group input, .form-group textarea {
        padding: 8.4px;
        border: 1px solid var(--border-color);
        border-radius: 2.8px;
        font-size: 11.2px;
        width: 100%;
    }
    .form-group textarea {
        height: 100%; /* Take 50% of the bottom-sheet height */
        min-height: 300px; /* Ensure a minimum height */
        resize: vertical; /* Allow vertical resizing */
        font-family: monospace;
        flex-grow: 1; /* Allow textarea to grow */
    }
    .submit-button {
        min-width: 30%;
        display: block;
        margin: 0 auto;
        padding: 10.5px;
        font-size: 12.6px;
        background-color: var(--primary-color);
        color: white;
        border: none;
        border-radius: 2.8px;
        cursor: pointer;
        transition: background-color 0.3s ease;
    }
    .submit-button:hover {
        background-color: #3A7BC8;
    }
</style>

<div id="overlay" class="overlay"></div>
<div class="bottom-sheet" id="sheet">
    <h3 id="title"></h3>
    <form id="editJsonSheet">
        <div class="form-group">
            <textarea id="valueInput" name="valueInput" placeholder='Enter a value' required></textarea>
        </div>
        <button type="submit" class="submit-button">Submit</button>
    </form>
</div>
        `;
    }

    show(value, title, onSubmit) {
        this.titleText.textContent = title
        this.onSubmit = onSubmit;
        this.valueInput.value = value;

        this.sheet.style.display = 'block';
        this.overlay.classList.add('show');
        setTimeout(() => this.sheet.classList.add('show'), 10);
    }

    hideSheet() {
        this.sheet.classList.remove('show');
        this.overlay.classList.remove('show');
        setTimeout(() => {
            this.sheet.style.display = 'none';
        }, 300);
    }

    handleSubmit(e) {
        e.preventDefault();
        let valueInput = this.valueInput.value;

        try {
            let data = JSON.parse(valueInput)
            this.onSubmit(data);
        } catch (e) {
            console.error("Invalid JSON:", e);
            alert(e)
            return;
        }

        this.hideSheet();
    }

}

customElements.define('edit-json-sheet', EditJsonSheet);
