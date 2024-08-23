public with sharing class movieChoiceController {

    @AuraEnabled(cacheable=true)
    public static List<tmdbSearchMovieResult> searchMovies(String title) {
        tmdb tmdbService = new tmdb();
        tmdbSearchMovieResponse response = tmdbService.searchMovie(title);
        
        if (response != null && response.results != null) {
            return response.results;
        }
        
        return new List<tmdbSearchMovieResult>();
    }
    
    
    
    @AuraEnabled
    public static void saveMovieData(Id movieRecordId, String tmdbId, String title, Decimal rating, String overview) {
        Movie__c movie = [SELECT Id, tmdb_id__c, TMDBSyncDate__c FROM Movie__c WHERE Id = :movieRecordId LIMIT 1];
        
        if (movie != null) {
            movie.tmdb_id__c = tmdbId;
            movie.TMDBSyncDate__c = Date.today();
            movie.Title__c = title;
            movie.Rating__c = rating;
            movie.Description__c = overview;
            update movie;
        }
    }
}