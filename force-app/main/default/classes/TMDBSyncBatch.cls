public class TMDBSyncBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {

        Date oneMonthAgo = Date.today().addMonths(-1);

        String query = 'SELECT Id, tmdb_id__c FROM Movie__c ' +
                       'WHERE (TMDBSyncDate__c = NULL OR TMDBSyncDate__c < :oneMonthAgo) ' +
                       'AND tmdb_id__c != NULL';
        
        return Database.getQueryLocator(query);
    }
    
    
    public void execute(Database.BatchableContext bc, List<Movie__c> scope) {
        List<Id> movieIds = new List<Id>();
        List<String> tmdbIds = new List<String>();

        for (Movie__c movie : scope) {
            movieIds.add(movie.Id);
            tmdbIds.add(movie.tmdb_id__c);
        }

        if (!tmdbIds.isEmpty()) {
            fetchMovieData.fetchMovieDataAsync(tmdbIds, movieIds);
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('TMDBSyncBatch completed successfully.');
    }
}