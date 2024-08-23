import { LightningElement, api, track } from 'lwc';
import searchMovies from '@salesforce/apex/movieChoiceController.searchMovies';
import saveMovieData from '@salesforce/apex/movieChoiceController.saveMovieData';
import getMovieTitle from '@salesforce/apex/MovieDataController.getMovieTitle';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class MovieChoice extends LightningElement {
    @track searchResults = [];
    @track errorMessage;
    @track successMessage;
    @api recordId;
    baseUrl = 'https://www.themoviedb.org/t/p/w600_and_h900_bestv2';

    connectedCallback() {
        this.fetchMovieTitle();
    }

    getMoviePosterUrl(posterPath) {
        return posterPath ? `${this.baseUrl}${posterPath}` : '';
    }

    fetchMovieTitle() {
        getMovieTitle({ recordId: this.recordId })
            .then(result => {
                if (result) {
                    this.searchMovies(result);
                } else {
                    this.errorMessage = 'Movie title not found.';
                }
            })
            .catch(error => {
                this.errorMessage = 'Error fetching movie title';
                console.error('Error fetching movie title:', error);
            });
    }

    searchMovies(title) {
        if (title) {
            searchMovies({ title: title })
                .then(result => {
                    this.searchResults = result.map(movie => {
                        
                        return {
                            ...movie,
                            posterUrl: this.getMoviePosterUrl(movie.poster_path)
                        };
                    });
                })
                .catch(error => {
                    this.searchResults = [];
                    this.errorMessage = 'Error retrieving movies.';
                    console.error('Error retrieving movies:', error);
                });
        }
    }

    handleSelectMovie(event) {
        const selectedMovieId = event.target.dataset.movieId;
        const selectedMovieTitle = event.target.dataset.movieTitle;
        const selectedMovieRating = event.target.dataset.movieRating;
        const selectedMovieOverview = event.target.dataset.movieOverview;

        saveMovieData({ 
            movieRecordId: this.recordId, 
            tmdbId: selectedMovieId, 
            title: selectedMovieTitle, 
            rating: selectedMovieRating, 
            overview: selectedMovieOverview 
        })
        .then(() => {
            this.successMessage = 'Movie data has been updated.';
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Movie data has been updated.',
                variant: 'success',
            }));
        })
        .catch(error => {
            this.errorMessage = 'An error occurred while updating the movie data.';
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'An error occurred while updating the movie data.',
                variant: 'error',
            }));
        });
    }
}
