trigger MovieTrigger on Movie__c (after insert, after update) {
    List<String> tmdbIdsForInsert = new List<String>();
    List<Id> movieRecordIdsForInsert = new List<Id>();

    List<String> tmdbIdsForUpdate = new List<String>();
    List<Id> movieRecordIdsForUpdate = new List<Id>();

    for (Movie__c movie : Trigger.new) {
        if (Trigger.isInsert) {
            if (movie.TMDB_Id__c != null) {
                tmdbIdsForInsert.add(movie.TMDB_Id__c);
                movieRecordIdsForInsert.add(movie.Id);
            }
        } else if (Trigger.isUpdate) {
            if (movie.TMDB_Id__c != null && (Trigger.oldMap.get(movie.Id).TMDB_Id__c != movie.TMDB_Id__c)) {
                tmdbIdsForUpdate.add(movie.TMDB_Id__c);
                movieRecordIdsForUpdate.add(movie.Id);
            }
        }
    }

    if (!tmdbIdsForInsert.isEmpty()) {
        fetchMovieData.fetchMovieDataAsync(tmdbIdsForInsert, movieRecordIdsForInsert);
    }

    if (!tmdbIdsForUpdate.isEmpty()) {
        fetchMovieData.fetchMovieDataAsync(tmdbIdsForUpdate, movieRecordIdsForUpdate);
    }
}
