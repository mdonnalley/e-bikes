import { LightningElement, api } from 'lwc';

export default class Paginator extends LightningElement {
    @api hasPreviousPage;
    @api hasNextPage;

    handlePrevious() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    handleNext() {
        this.dispatchEvent(new CustomEvent('next'));
    }
}
