import '../component/OnboardBrandBottomSheet.js';
import '../component/ConfirmationDialog.js';
import '../component/MessageBottomSheet.js';
import '../component/BrandOptionsBottomSheet.js';
import '../component/AliasesBottomSheet.js';

class BrandsView {
    constructor(source) {
        this.source = source
        this.brandList = document.getElementById('brandList');
        this.currentBrandSection = document.getElementById('currentBrandSection');
        this.currentBrandItem = document.getElementById('currentBrandItem');
        this.brandOptionsSheet = document.getElementById('bottomSheet');
        this.confirmationDialog = document.getElementById('confirmationDialog');
        this.messageBottomSheet = document.getElementById('messageBottomSheet');
        this.onboardSheet = document.getElementById('onboardBottomSheet');
    }

    createBrandItem(brand, isCurrent = false) {
        const brandItem = document.createElement('div');
        brandItem.className = 'brand-item';
        brandItem.innerHTML = `
            <div class="brand-image">
                <img src="../brand/icon?brand_key=${brand.key}" alt="${brand.name} icon">
            </div>
            <div class="brand-info">
                <div class="brand-name">${brand.name}</div>
                <div class="brand-key">${brand.key}</div>
            </div>
            <div class="brand-actions">
                <button class="switch-button">Switch</button>
                <div class="overflow-menu">
                    <i class="fas fa-ellipsis-v"></i>
                </div>
            </div>
        `;

        brandItem.addEventListener('click', () => {
            window.location.href = this.brandUrl(brand.key);
        });

        const switchButton = brandItem.querySelector('.switch-button');
        if (isCurrent && brand.content_changed) {
            switchButton.textContent = "Apply Changes";
            switchButton.style.display = "block";
        } else if (isCurrent && !brand.content_changed) {
            switchButton.style.display = "none";
        } else {
            switchButton.style.display = "block";
        }

        switchButton.addEventListener('click', async (event) => {
            event.stopPropagation(); // Prevent the click from bubbling up to the parent
            await this.onSwitch(brand.key);
        });

        // Add click event for the overflow menu
        const overflowMenu = brandItem.querySelector('.overflow-menu');
        overflowMenu.addEventListener('click', (event) => {
            event.stopPropagation();
            this.showBrandOptionsSheet(brand);
        });

        brandItem.dataset.brand = brand.key;
        return brandItem;
    }

    renderBrands(brands, currentBrand) {
        this.brandList.innerHTML = '';
        this.currentBrandItem.innerHTML = '';

        if (currentBrand) {
            this.currentBrandSection.style.display = 'block';
            this.currentBrandItem.appendChild(this.createBrandItem(currentBrand, true));
        }

        brands.forEach(brand => {
            if (!currentBrand || brand.key !== currentBrand.key) {
                const brandItem = this.createBrandItem(brand);
                this.brandList.appendChild(brandItem);
            }
        });
    }

    showOnboardBrandForm() {
        this.onboardSheet.show();
    }

    async hideOnboardBrandForm() {
        this.onboardSheet.hide();
    }

    showAliasesBottomSheet(aliases, brandKey) {
        const aliasesSheet = document.getElementById('aliasesSheet');
        aliasesSheet.show(aliases, brandKey);
    }

    showBrandOptionsSheet(brand) {
        this.brandOptionsSheet.dataset.brandName = brand.name;
        this.brandOptionsSheet.dataset.brandKey = brand.key;
        this.brandOptionsSheet.show();
    }

    showConfirmationDialog(message, onConfirm) {
        this.confirmationDialog.showDialog(message, onConfirm);
    }

    showMessage(message) {
        this.messageBottomSheet.showMessage(message);
    }

    updateErrorCount(count) {
        const countElement = document.querySelector('.count');
        countElement.textContent = count;
    }

    showErrorButton() {
        const errorButton = document.getElementById('error-button');
        errorButton.style.display = "flex";
    }

    hideErrorButton() {
        const errorButton = document.getElementById('error-button');
        errorButton.style.display = "none";
    }

    setOnSwitch(handler) {
        this.onSwitch = handler;
    }

    brandUrl(brandKey) {
        return `../brand/brand.html?brand_key=${encodeURIComponent(brandKey)}&source=${this.source}`;
    }
}

export default BrandsView;