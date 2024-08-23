import { LightningElement, api, wire, track } from 'lwc';
import getMovieVideos from '@salesforce/apex/MovieTrailerController.getMovieVideos';
import getMovieById from '@salesforce/apex/MovieTrailerController.getMovieById';

export default class MovieTrailer extends LightningElement {
    @api recordId; 
    @track trailerKey;
    @track error;
    @track tmdbId;

    @wire(getMovieById, { movieId: '$recordId' })
    wiredMovie({ error, data }) {
        if (data) {
            this.tmdbId = data.tmdb_id__c;
        } else if (error) {
            console.error('Error retrieving movie:', JSON.stringify(error)); // Отладочный вывод
            this.error = error;
        }
    }

    @wire(getMovieVideos, { tmdbId: '$tmdbId' })
    wiredVideos({ error, data }) {
        if (data) {
            console.log('Received data:', JSON.stringify(data)); // Отладочный вывод
            
            const trailer = data.find(video => video.site === 'YouTube' && video.type === 'Trailer');
            if (trailer) {
                this.trailerKey = trailer.key;
            } else {
                this.trailerKey = null;
            }
        } else if (error) {
            console.error('Error retrieving videos:', JSON.stringify(error)); // Отладочный вывод
            this.error = error;
            this.trailerKey = null;
        }
    }

    get youtubeUrl() {
        return this.trailerKey ? `https://www.youtube.com/embed/${this.trailerKey}` : null;
    }
}
