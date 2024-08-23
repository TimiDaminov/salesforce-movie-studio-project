import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import parseAndCreateMovies from '@salesforce/apex/MovieDataUploaderController.parseAndCreateMovies';

export default class MovieDataUploader extends LightningElement {
    @api recordId;

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        if (uploadedFiles.length > 0) {
            const fileId = uploadedFiles[0].documentId;
            this.processUploadedFile(fileId);
        }
    }

    processUploadedFile(fileId) {
        parseAndCreateMovies({ contentDocumentId: fileId })
            .then(() => {
                this.showToast('Success', 'Records loaded successfully.', 'success');
            })
            .catch(error => {
                this.showToast('Error', `Error processing file: ${error.body.message}`, 'error');
            });
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}
