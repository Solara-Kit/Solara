import BrandsModel from './BrandsModel.js';
import BrandsView from './BrandsView.js';
import BrandsController from './BrandsController.js';

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

document.addEventListener('DOMContentLoaded', async () => {
    const model = new BrandsModel();
    const view = new BrandsView(model.source);
    const controller = new BrandsController(model, view);
    await controller.init();
});