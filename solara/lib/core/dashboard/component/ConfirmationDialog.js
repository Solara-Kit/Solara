class ConfirmationDialog extends HTMLElement {
    constructor() {
        super();
        this.attachShadow({mode: 'open'});
        this.render();
    }

    render() {
        this.shadowRoot.innerHTML = `
    <style>
    .title {
        color: var(--text-color);
        font-size: 14px;
    }
    .confirmation-dialog {
        display: none;
        position: fixed;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background-color: var(--background-color);
        border-radius: 7px;
        box-shadow: 0 2.8px 4.2px rgba(0, 0, 0, 0.1);
        z-index: 1001;
        text-align: center;
        font-size: 11px;
        padding: 20px;
    }
    .confirmation-dialog h3 {
        margin-top: 0;
        color: var(--primary-color);
        font-size: 15px;
    }
    .confirmation-dialog .buttons {
        margin-top: 14px;
    }
    .confirmation-dialog button {
        margin: 0 7px;
        padding: 7px 14px;
        border: none;
        border-radius: 3.5px;
        cursor: pointer;
        font-size: 11.2px;
        transition: background-color 0.3s ease;
    }
    .confirmation-dialog .confirm {
        background-color: #dc3545;
        color: white;
        margin-top: 10px;
    }
    .confirmation-dialog .cancel {
        background-color: #ccc;
        color: #333;
        margin-top: 10px;
     }
    .confirmation-dialog .confirm:hover {
        background-color: var(--hover);
    }
    .confirmation-dialog .cancel:hover {
        background-color: var(--hover);
    }
    .overlay {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5);
        z-index: 999;
    }
</style>
<div class="overlay" id="overlay"></div>
<div class="confirmation-dialog" id="confirmationDialog">
    <h2 class="title" id="confirmationMessage"></h2>
    <div class="buttons">
        <button class="confirm" id="confirmButton">Confirm</button>
        <button class="cancel" id="cancelButton">Cancel</button>
    </div>
</div>
        `;

        this.confirmationDialog = this.shadowRoot.getElementById('confirmationDialog');
        this.overlay = this.shadowRoot.getElementById('overlay');
        this.confirmButton = this.shadowRoot.getElementById('confirmButton');
        this.cancelButton = this.shadowRoot.getElementById('cancelButton');
        this.confirmationMessageElement = this.shadowRoot.getElementById('confirmationMessage');

        this.cancelButton.onclick = () => this.hide();
        this.overlay.onclick = () => this.hide();
    }

    showDialog(message, onConfirm) {
        this.confirmationMessageElement.textContent = message;
        this.confirmationDialog.style.display = 'block';
        this.overlay.style.display = 'block';

        this.confirmButton.onclick = () => {
            onConfirm();
            this.hide();
        };
    }

    hide() {
        this.confirmationDialog.style.display = 'none';
        this.overlay.style.display = 'none';
    }
}

customElements.define('confirmation-dialog', ConfirmationDialog);