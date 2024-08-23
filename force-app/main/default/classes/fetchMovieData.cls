public class fetchMovieData {
    @future(callout=true)
    public static void fetchMovieDataAsync(List<String> tmdbIds, List<Id> movieRecordIds) {
        try {
            System.debug('TMDB IDs: ' + tmdbIds);
            System.debug('Movie Record IDs: ' + movieRecordIds);

            if (tmdbIds == null || movieRecordIds == null || tmdbIds.size() != movieRecordIds.size()) {
                throw new IllegalArgumentException('TMDB IDs and Movie Record IDs must be non-null and of equal length.');
            }

            Map<String, tmdb.tmdbMovieResponse> tmdbIdToMovieDataMap = new Map<String, tmdb.tmdbMovieResponse>();
            tmdb tmdbService = new tmdb();

            for (String tmdbId : tmdbIds) {
                tmdb.tmdbMovieResponse movieData = tmdbService.getMovieById(tmdbId);
                if (movieData != null) {
                    tmdbIdToMovieDataMap.put(tmdbId, movieData);
                }
            }

            List<Movie__c> movieRecordsToUpdate = new List<Movie__c>();

            for (Integer i = 0; i < tmdbIds.size(); i++) {
                String tmdbId = tmdbIds[i];
                Id recordId = movieRecordIds[i];
                
                tmdb.tmdbMovieResponse movieData = tmdbIdToMovieDataMap.get(tmdbId);
                if (movieData != null) {
                    Movie__c movieRecord = new Movie__c(
                        Id = recordId,
                        Description__c = movieData.overview,
                        Title__c = movieData.original_title,
                        Poster_URL__c = 'https://image.tmdb.org/t/p/original/' + movieData.poster_path,
                        Budget__c = movieData.budget,
                        Rating__c = movieData.vote_average,
                        Number__c = movieData.revenue,
                        TMDBSyncDate__c = Date.today()
                    );
                    movieRecordsToUpdate.add(movieRecord);
                }
            }

            if (!movieRecordsToUpdate.isEmpty()) {
                update movieRecordsToUpdate;
            }
        } catch (Exception e) {
            System.debug('Error in fetchMovieDataAsync: ' + e.getMessage());
        }
    }
}
