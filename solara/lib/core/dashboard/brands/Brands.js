import BrandsModel from './BrandsModel.js';
import BrandsView from './BrandsView.js';
import BrandsController from './BrandsController.js';

document.addEventListener('DOMContentLoaded', async () => {
    const model = new BrandsModel();
    const view = new BrandsView(model.source);
    const controller = new BrandsController(model, view);
    await controller.init();
});