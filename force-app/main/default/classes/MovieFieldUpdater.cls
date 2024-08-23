public class MovieFieldUpdater implements Database.Batchable<sObject> {
    public static final Integer BATCH_SIZE = 200; // Adjust batch size as needed

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Query records with TMDBSyncDate__c blank or older than 1 month and tmdb_id__c not empty
        String query = 'SELECT Id, tmdb_id__c, Number__c, Rating__c, TMDBSyncDate__c ' +
                       'FROM Movie__c ' +
                       'WHERE (TMDBSyncDate__c = NULL OR TMDBSyncDate__c < LAST_N_DAYS:30) ' +
                       'AND tmdb_id__c != NULL';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Movie__c> scope) {
        // Create an instance of the tmdb class
        tmdb tmdbService = new tmdb();
        
        // List to hold the movies to update
        List<Movie__c> moviesToUpdate = new List<Movie__c>();

        for (Movie__c movie : scope) {
            if (movie.tmdb_id__c != null) {
                try {
                    // Fetch movie data from TMDB
                    tmdb.tmdbMovieResponse movieInfo = tmdbService.getMovieById(movie.tmdb_id__c);

                    // Debugging output
                    System.debug('Fetched movie data for TMDB ID: ' + movie.tmdb_id__c);
                    System.debug('Movie Info: ' + movieInfo);
                    
                    if (movieInfo != null) {
                        // Prepare the movie record for update
                        Movie__c movieToUpdate = new Movie__c(Id = movie.Id);
                        movieToUpdate.Number__c = movieInfo.revenue; // Ensure this field is intended to store revenue
                        movieToUpdate.Rating__c = movieInfo.vote_average;
                        movieToUpdate.TMDBSyncDate__c = Date.today();
                        
                        moviesToUpdate.add(movieToUpdate);
                    } else {
                        System.debug('No movie info found for TMDB ID: ' + movie.tmdb_id__c);
                    }
                } catch (Exception e) {
                    // Handle exceptions (e.g., log errors)
                    System.debug('Error fetching data for TMDB ID: ' + movie.tmdb_id__c + ' - ' + e.getMessage());
                }
            }
        }

        if (!moviesToUpdate.isEmpty()) {
            // Perform the update operation
            try {
                update moviesToUpdate;
                System.debug('Updated records: ' + moviesToUpdate);
            } catch (DmlException e) {
                // Handle DML exceptions (e.g., log errors)
                System.debug('Error updating records: ' + e.getMessage());
            }
        } else {
            System.debug('No records to update.');
        }
    }

}
