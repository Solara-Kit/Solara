class OnboardBrandBottomSheet extends HTMLElement {
    constructor() {
        super();
        this.attachShadow({mode: 'open'});
        this.onSubmit = null;
    }

    connectedCallback() {
        this.render();
        this.setupEventListeners();
    }

    render() {
        this.shadowRoot.innerHTML = `
      <head>
    <style>
        .overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: rgba(0, 0, 0, 0.5);
            z-index: 999;
        }
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
            max-width: 490px;
            margin: 0 auto;
            width: 100%;
        }
        .bottom-sheet.show {
            transform: translateY(0);
        }
        h3 {
            color: var(--primary-color, #4A90E2);
            margin-top: 0;
            font-size: 15.4px;
        }
        .onboard-brand-form {
            display: flex;
            flex-direction: column;
            gap: 10.5px;
        }
        .form-group {
            display: flex;
            flex-direction: column;
        }
        .form-group label {
            display: flex;
            align-items: center;
            margin-bottom: 3.5px;
            font-weight: bold;
            font-size: 11.2px;
        }
        .form-group input {
            padding: 7px;
            border: 0.7px solid var(--border-color, #E1E4E8);
            border-radius: 3.5px;
            font-size: 11.2px;
            background-color: var(--background-color);
        }
        .tooltip {
            position: relative;
            display: inline-block;
            margin: 3.5px;
        }
        .tooltip .tooltiptext {
            visibility: hidden;
            width: 140px;
            background-color: #555;
            color: #fff;
            text-align: center;
            border-radius: 4.2px;
            padding: 3.5px;
            position: absolute;
            z-index: 1;
            bottom: 125%;
            left: 50%;
            margin-left: -70px;
            opacity: 0;
            transition: opacity 0.3s;
            font-size: 9.8px;
        }
        .tooltip:hover .tooltiptext {
            visibility: visible;
            opacity: 1;
        }
        .onboard-brand-button {
            background-color: var(--primary-color, #4A90E2);
            color: white;
            border: none;
            padding: 7px 14px;
            border-radius: 3.5px;
            cursor: pointer;
            font-size: 11.2px;
            transition: background-color 0.3s ease;
            margin-top: 30px;
        }
        .onboard-brand-button:hover {
            background-color: var(--hover);
        }
    </style>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css">
</head>
<div>
    <div class="overlay" id="overlay"></div>
    <div class="bottom-sheet" id="onboardBrandSheet">
        <h2 id="sheetTitle">Onboard New Brand</h2>
        <form class="onboard-brand-form" id="onboardBrandForm">
            <div class="form-group">
                <label for="brandKey">
                    Brand Key
                    <div class="tooltip">
                        <i class="fas fa-question-circle question-icon"></i>
                        <span class="tooltiptext">Brand key will be added to the brands.json and is used to identify the brand with a unique name. It must match the brand folder in brands.</span>
                    </div>
                </label>
                <input type="text" id="brandKey" name="brandKey" required>
            </div>
            <div class="form-group">
                <label for="brandName">
                    Brand Name
                    <div class="tooltip">
                        <i class="fas fa-question-circle question-icon"></i>
                        <span class="tooltiptext">The brand name will be added to the brands.json and is used to identify the brand in Solara. It is not used in the actual app.</span>
                    </div>
                </label>
                <input type="text" id="brandName" name="brandName" required>
            </div>
            <button id="submitBtn" type="submit" class="onboard-brand-button">Onboard Brand</button>
        </form>
    </div>
</div>
        `;
    }

    setupEventListeners() {
        const form = this.shadowRoot.getElementById('onboardBrandForm');
        form.addEventListener('submit', (e) => {
            e.preventDefault();
            this.submit();
        });
    }

    submit() {
        const brandKey = this.shadowRoot.getElementById('brandKey').value;
        const brandName = this.shadowRoot.getElementById('brandName').value;

        const brandKeyRegex = /^[A-Za-z][A-Za-z0-9_-]*$/;

        if (!brandKeyRegex.test(brandKey)) {
            alert('Brand key must start with a letter and contain no spaces. Only letters, numbers, underscores, and hyphens are allowed.');
            return;
        }

        this.dispatchEvent(new CustomEvent('onboard', {
            detail: {brandKey, brandName},
            bubbles: true,
            composed: true
        }));

        // Call the onSubmit if it's defined
        if (this.onSubmit) {
            this.onSubmit(brandKey, brandName);
        }

        this.hide();
    }

    show(title, submitTitle, onSubmit) {
        this.onSubmit = onSubmit; // Store the onSubmit function

        // Set the title and submit title in the respective elements
        if (title)
            this.shadowRoot.getElementById('sheetTitle').textContent = title;
        if (submitTitle)
            this.shadowRoot.getElementById('submitBtn').textContent = submitTitle;

        // Reference the sheet element and display it
        const sheet = this.shadowRoot.getElementById('onboardBrandSheet');
        sheet.style.display = 'block'; // Make the sheet visible

        // Use a timeout to allow for smooth transitions
        setTimeout(() => {
            sheet.classList.add('show'); // Add 'show' class for CSS transitions
            this.overlay = this.shadowRoot.getElementById('overlay');
            this.overlay.style.display = 'block'; // Show the overlay

            // Set up the overlay click event to hide the sheet
            this.overlay.onclick = () => this.hide();
        }, 10);
    }

    hide() {
        const sheet = this.shadowRoot.getElementById('onboardBrandSheet');
        sheet.classList.remove('show');
        setTimeout(() => {
            sheet.style.display = 'none';
            this.overlay.style.display = 'none';
        }, 300);
    }

}

customElements.define('onboard-bottom-sheet', OnboardBrandBottomSheet);