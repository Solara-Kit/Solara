class MessageBottomSheet extends HTMLElement {
    constructor() {
        super();
        this.attachShadow({mode: 'open'});
        this.shadowRoot.innerHTML = `
           <style>
    .message-bottom-sheet {
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
        max-width: 700px;
        margin: 0 auto;
        width: 100%;
    }
    .message-bottom-sheet.show {
        transform: translateY(0);
    }
    .message-content {
        max-height: 210px; /* Reduced from 300px */
        overflow-y: auto;
        margin-bottom: 14px;
    }
    .close-message {
        width: 7%;
        margin: 14px;
        padding: 7px;
        background-color: var(--primary-color);
        color: white;
        border: none;
        border-radius: 3.5px;
        cursor: pointer;
        font-size: 11.2px;
    }
    .close-message:hover {
        background-color: #0056b3;
    }
</style>
<div class="message-bottom-sheet" id="messageBottomSheet">
    <div class="message-content" id="messageContent"></div>
    <button class="close-message" id="closeMessage">Close</button>
</div>
<div id="overlay" class="overlay" style="display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0, 0, 0, 0.5); z-index: 999;"></div>
    `;

        this.messageBottomSheet = this.shadowRoot.getElementById('messageBottomSheet');
        this.messageContent = this.shadowRoot.getElementById('messageContent');
        this.closeMessageButton = this.shadowRoot.getElementById('closeMessage');
            this.overlay = this.shadowRoot.getElementById('overlay');

        this.closeMessageButton.onclick = () => this.hideMessage();
        this.overlay.onclick = () => this.hideMessage();
    }

    showMessage(message) {
        this.messageContent.innerHTML = message.replace(/\n/g, '<br>');
        this.messageBottomSheet.style.display = 'block';
        this.overlay.style.display = 'block';
        setTimeout(() => this.messageBottomSheet.classList.add('show'), 10);
    }

    hideMessage() {
        this.messageBottomSheet.classList.remove('show');
        setTimeout(() => {
            this.messageBottomSheet.style.display = 'none';
            this.overlay.style.display = 'none';
        }, 300);
    }
}

customElements.define('message-bottom-sheet', MessageBottomSheet);