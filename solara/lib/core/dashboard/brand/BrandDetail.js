// app.js
import BrandDetailModel from './BrandDetailModel.js';
import BrandDetailView from './BrandDetailView.js';
import BrandDetailController from './BrandDetailController.js';

window.onload = function () {
    document.getElementById('loadingOverlay').style.display = 'none';
};

let lastScrollTop = 0;
const header = document.getElementById('header');

window.addEventListener('scroll', function () {
    let scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    if (scrollTop > lastScrollTop) {
        // Scrolling down
        header.classList.add('scroll-down');
    } else {
        // Scrolling up
        header.classList.remove('scroll-down');
    }
    lastScrollTop = scrollTop;
});
        
document.addEventListener('DOMContentLoaded', async () => {
    const model = new BrandDetailModel();
    const view = new BrandDetailView(model);
    const controller = new BrandDetailController(model, view);
    await controller.initializeApp();
});