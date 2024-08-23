import { LightningElement, track, wire } from 'lwc';
import getMovies from '@salesforce/apex/MovieCatalogController.getMovies';
import getGenres from '@salesforce/apex/MovieCatalogController.getGenres';

const DEFAULT_LIMIT = 10;

export default class MovieCatalog extends LightningElement {
    @track allMovies = [];
    @track filteredMovies = [];
    @track genres = [];
    @track genreFilter = '';
    @track movieLimit = DEFAULT_LIMIT;
    @track offset = 0;

    @wire(getMovies)
    wiredMovies({ data, error }) {
        if (data) {
            this.allMovies = Array.from(data);
            this.applyFilters();
        } else if (error) {
            console.error('Error loading movies:', error);
        }
    }

    @wire(getGenres)
    wiredGenres({ data, error }) {
        if (data) {
            this.genres = Array.from(data).map(genre => ({ label: genre, value: genre })); 
        } else if (error) {
            console.error('Error loading genres:', error);
        }
    }

    handleFilterChange(event) {
        this.genreFilter = event.target.value.trim().toLowerCase();
        this.offset = 0;
        this.applyFilters();
    }

    handleLimitChange(event) {
        this.movieLimit = parseInt(event.target.value, 10);
        this.offset = 0;
        this.applyFilters();
    }

    handleNext() {
        this.offset += this.movieLimit;
        this.applyFilters();
    }

    handlePrevious() {
        this.offset = Math.max(this.offset - this.movieLimit, 0);
        this.applyFilters();
    }

    applyFilters() {
        if (this.allMovies.length === 0) {
            this.filteredMovies = [];
            return;
        }

        let filtered = [...this.allMovies];
        if (this.genreFilter) {
            filtered = filtered.filter(movie => {
                const genres = movie.Genre__c ? movie.Genre__c.split(';').map(genre => genre.trim().toLowerCase()) : [];
                return genres.includes(this.genreFilter);
            });
        }

        this.filteredMovies = filtered.slice(this.offset, this.offset + this.movieLimit);
    }
}
