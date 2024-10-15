import {DataSource} from './BrandDetailModel.js';
import SectionsFormManager from './SectionsFormManager.js';
import '../component/OnboardBrandBottomSheet.js';
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
        this.confirmationDialog = document.getElementById('confirmationDialog');
        this.messageBottomSheet = document.getElementById('messageBottomSheet');

        this.uploadBrandBtn = document.getElementById('uploadBrandBtn');
        this.uploadJsonBtn = document.getElementById('uploadJsonBtn');
        this.addNewBrandBtn = document.getElementById('newBrandBtn');
        this.exportBrandBtn = document.getElementById('exportBrandBtn');
        this.allBrandsButton = document.getElementById('allBrandsButton');
        this.syncBrandButton = document.getElementById('syncBrandButton');
        this.onboardSheet = document.getElementById('onboardBottomSheet');
        this.sectionsFormManager = new SectionsFormManager();

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

    showConfirmationDialog(message, onConfirm) {
        this.confirmationDialog.showDialog(message, onConfirm);
    }

    setupSyncBrandButton(color) {
        this.header.style.backgroundColor = color;
        this.syncBrandButton.style.backgroundColor = color;
        this.syncBrandButton.style.display = 'block';
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

    async toast(message) {
        const toastElement = document.getElementById('toast');
        toastElement.textContent = message;
        toastElement.style.display = 'block';

        setTimeout(() => {
            toastElement.style.display = 'none';
        }, 3000);
    }


}

export default BrandDetailView;