import BrandDetailModel from './BrandDetailModel.js';
import BrandDetailView from './BrandDetailView.js';
import BrandDetailController from './BrandDetailController.js';

const modeToggle = document.getElementById('modeToggle');
const body = document.body;
const icon = modeToggle.querySelector('i');

function applyMode(mode) {
    if (mode === 'dark') {
        body.classList.add('dark-mode');
        icon.classList.remove('fa-sun');
        icon.classList.add('fa-moon');
    } else {
        body.classList.remove('dark-mode');
        icon.classList.remove('fa-moon');
        icon.classList.add('fa-sun');
    }
}

const savedMode = localStorage.getItem('mode');
if (savedMode) {
    applyMode(savedMode);
} else {
    const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    applyMode(systemPrefersDark ? 'dark' : 'light');
}

modeToggle.addEventListener('click', () => {
    const currentMode = body.classList.contains('dark-mode') ? 'dark' : 'light';
    const newMode = currentMode === 'dark' ? 'light' : 'dark';
    applyMode(newMode);
    localStorage.setItem('mode', newMode);
});

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

