class AliasesBottomSheet extends HTMLElement {
    constructor() {
        super();
        this.attachShadow({ mode: 'open' });
        this.shadowRoot.innerHTML = `
          <style>
    .aliases-bottom-sheet {
        display: none;
        position: fixed;
        bottom: 0;
        left: 0;
        right: 0;
        background-color: white;
        border-top-left-radius: 14px;
        border-top-right-radius: 14px;
        box-shadow: 0 -1.4px 7px rgba(0, 0, 0, 0.1);
        z-index: 1000;
        padding: 14px;
        transition: transform 0.3s ease-out;
        transform: translateY(100%);
        max-width: 490px;
        margin: 0 auto;
        width: 100%;
        max-height: 56vh;
        overflow-y: auto;
    }
    .aliases-bottom-sheet.show {
        transform: translateY(0);
    }
    .aliases-bottom-sheet h3 {
        color: var(--primary-color);
        margin-top: 0;
        font-size: 16.8px;
    }
    .aliases-bottom-sheet h4 {
        font-size: 14px;
    }
    .aliases-bottom-sheet ul {
        list-style-type: none;
        padding: 0;
    }
    .aliases-bottom-sheet li {
        margin-bottom: 7px;
        font-family: monospace;
        background-color: #f1f1f1;
        padding: 3.5px;
        border-radius: 3.5px;
        font-size: 11.2px;
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
    .close-aliases {
        background-color: var(--primary-color);
        color: white;
        border: none;
        padding: 7px 14px;
        border-radius: 3.5px;
        cursor: pointer;
        font-size: 11.2px;
        transition: background-color 0.3s ease;
        margin-top: 14px;
    }
    .close-aliases:hover {
        background-color: #3a7bc8;
    }
</style>

<div class="overlay"></div>
<div class="aliases-bottom-sheet" id="aliasesSheet">
    <h3>Aliases</h3>
    <div id="commonAliases">
        <h4>Common Aliases</h4>
        <ul id="commonAliasesList"></ul>
    </div>
    <div id="brandAliases">
        <h4>Brand Aliases</h4>
        <ul id="brandAliasesList"></ul>
    </div>
    <button class="close-aliases" id="closeAliases">Close</button>
</div>
        `;

        this.aliasesBottomSheet = this.shadowRoot.getElementById('aliasesSheet');
        this.overlay = this.shadowRoot.querySelector('.overlay');
        this.closeAliasesBtn = this.shadowRoot.getElementById('closeAliases');

        this.closeAliasesBtn.onclick = () => this.hide();
        this.overlay.onclick = () => this.hide();
    }

    show(aliases, brandKey) {
        const commonAliasesList = this.shadowRoot.getElementById('commonAliasesList');
        const brandAliasesList = this.shadowRoot.getElementById('brandAliasesList');

        commonAliasesList.innerHTML = '';
        brandAliasesList.innerHTML = '';

        const pattern = /alias|='[^']*'/g;

        aliases.aliases.common_aliases.forEach(alias => {
            const li = document.createElement('li');
            li.textContent = alias[0].replace(pattern, '').trim();
            commonAliasesList.appendChild(li);
        });

        const brandAliases = aliases.aliases.brand_aliases[brandKey] || [];

        brandAliases.forEach(alias => {
            const li = document.createElement('li');
            li.textContent = alias[0].replace(pattern, '').trim();
            brandAliasesList.appendChild(li);
        });
        this.aliasesBottomSheet.style.display = 'block';
        this.overlay.style.display = 'block';

        setTimeout(() => this.aliasesBottomSheet.classList.add('show'), 10);
    }

    hide() {
        this.aliasesBottomSheet.classList.remove('show');
        setTimeout(() => {
            this.aliasesBottomSheet.style.display = 'none';
            this.overlay.style.display = 'none';
        }, 300); // Match with the CSS transition duration
    }
}

customElements.define('aliases-bottom-sheet', AliasesBottomSheet);