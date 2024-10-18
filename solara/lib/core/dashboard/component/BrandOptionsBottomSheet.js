class BrandOptionsBottomSheet extends HTMLElement {
    constructor() {
        super();
        this.attachShadow({mode: 'open'});

        this.shadowRoot.innerHTML = `
    <head>
    <style>
    .bottom-sheet {
        display: none;
        position: fixed;
        bottom: 0;
        left: 0;
        right: 0;
        background-color: var(--background-color);
        border-top-left-radius: 14px;
        border-top-right-radius: 14px;
        box-shadow: 0 -1.4px 7px rgba(0, 0, 0, 0.1);
        z-index: 1000;
        padding: 14px;
        transition: transform 0.3s ease-out;
        transform: translateY(100%);
        max-width: 50%;
        margin: 0 auto;
        width: 100%;
    }
    .bottom-sheet.show {
        transform: translateY(0);
    }
    .bottom-sheet ul {
        list-style-type: none;
        padding: 0;
        margin: 0;
    }
    .bottom-sheet li {
        padding: 10.5px 14px;
        cursor: pointer;
        transition: background-color 0.3s ease;
        display: flex;
        align-items: center;
        font-size: 12.6px;
    }
    .bottom-sheet li:hover {
        background-color: var(--hover);
    }
    .bottom-sheet li i {
        margin-right: 10.5px;
        font-size: 14px;
        width: 16.8px;
        text-align: center;
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
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
</head>
<div class="overlay"></div>
<div class="bottom-sheet" id="bottomSheet">
    <ul>
        <li id="cloneOption" class="clone-option"><i class="fas fa-copy"></i>Clone</li>
        <li id="doctorOption" class="doctor-option"><i class="fas fa-stethoscope"></i>Doctor</li>
        <li id="offboardOption" class="offboard-option"><i class="fas fa-trash-alt"></i>Offboard</li>
        <li id="aliasesOption" class="aliases-option"><i class="fas fa-terminal"></i>Terminal aliases</li>
        <li id="settingsOption" class="settings-option"><i class="fas fa-cog"></i>Settings</li>
    </ul>
</div>
        `;

        this.bottomSheet = this.shadowRoot.getElementById('bottomSheet');
        this.overlay = this.shadowRoot.querySelector('.overlay');

        this.shadowRoot.getElementById('cloneOption').onclick = this.handleCloneOption.bind(this);
        this.shadowRoot.getElementById('offboardOption').onclick = this.handleOffboardOption.bind(this);
        this.shadowRoot.getElementById('doctorOption').onclick = this.handleDoctorOption.bind(this);
        this.shadowRoot.getElementById('aliasesOption').onclick = this.handleAliasesOption.bind(this);
        this.shadowRoot.getElementById('settingsOption').onclick = this.handleSettingsOption.bind(this);

        this.overlay.onclick = this.hideBrandOptionsBottomSheet.bind(this);
    }

    show() {
        this.bottomSheet.style.display = 'block';
        this.overlay.style.display = 'block';
        setTimeout(() => this.bottomSheet.classList.add('show'), 10);
    }

    hideBrandOptionsBottomSheet() {
        this.bottomSheet.classList.remove('show');
        this.overlay.style.display = 'none';
    }

    handleCloneOption(event) {
        event.stopPropagation();
        this.hideBrandOptionsBottomSheet();
        this.dispatchEvent(new CustomEvent('clone', {detail: this.bottomSheet.dataset}));
    }

    handleOffboardOption(event) {
        event.stopPropagation();
        this.hideBrandOptionsBottomSheet();
        this.dispatchEvent(new CustomEvent('offboard', {detail: this.bottomSheet.dataset}));
    }

    handleDoctorOption(event) {
        event.stopPropagation();
        this.hideBrandOptionsBottomSheet();
        this.dispatchEvent(new CustomEvent('doctor', {detail: this.bottomSheet.dataset}));
    }

    handleAliasesOption(event) {
        event.stopPropagation();
        this.hideBrandOptionsBottomSheet();
        this.dispatchEvent(new CustomEvent('aliases', {detail: this.bottomSheet.dataset}));
    }

    handleSettingsOption(event) {
        event.stopPropagation();
        this.hideBrandOptionsBottomSheet();
        this.dispatchEvent(new CustomEvent('settings', {detail: this.bottomSheet.dataset}));
    }
}

customElements.define('brand-options-bottom-sheet', BrandOptionsBottomSheet);