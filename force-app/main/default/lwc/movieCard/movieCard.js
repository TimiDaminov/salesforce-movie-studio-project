import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class MovieCard extends NavigationMixin(LightningElement) {
    @api movie;

    get isHorror() {
        return this.movie.Genre__c && this.movie.Genre__c.includes('Horror');
    }
    
    handleDetailsClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.movie.Id,
                objectApiName: 'Movie__c', 
                actionName: 'view'
            }
        });
    }
}
