// public class tmdbFetchDataTriggerHandler {
//     @future(callout=true)
//     public static void fetchMovieDataAsync(String tmdbId, Id movieRecordId) {
//         try {
//             tmdb tmdbService = new tmdb();
//             tmdb.tmdbMovieResponse movieInfo = tmdbService.getMovieById(tmdbId);

//             if (movieInfo != null) {
                
//                 String debugMessage = 'Movie info is: ' +
//                                       'Overview: ' + movieInfo.overview + ', ' +
//                                       'Original Title: ' + movieInfo.original_title + ', ' +
//                                       'Revenue: ' + movieInfo.revenue + ', ' +
//                                       'Vote Average: ' + movieInfo.vote_average + ', ' +
//                                       'Poster Path: ' + movieInfo.poster_path + ', ' +
//                                       'Budget: ' + movieInfo.budget;

//                 System.debug(debugMessage);

                
//                 Movie__c movieToUpdate = [SELECT Id FROM Movie__c WHERE Id = :movieRecordId LIMIT 1];

            
//                 if (movieToUpdate != null) {
//                     movieToUpdate.Description__c = movieInfo.overview;
//                     movieToUpdate.Title__c = movieInfo.original_title;
//                     movieToUpdate.Poster_URL__c = 'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/' + movieInfo.poster_path;
//                     movieToUpdate.Budget__c = movieInfo.budget;
//                     movieToUpdate.Number__c = movieInfo.revenue;
// 					movieToUpdate.Rating__c = movieInfo.vote_average;
                    
//                     System.debug('Updating Movie__c record with ID: ' + movieToUpdate.Id);
//                     System.debug('Fields to update: ' + movieToUpdate);

                    
//                     update movieToUpdate;

                    
//                     System.debug('Record updated successfully');
//                 } else {
//                     System.debug('Movie__c record not found with ID: ' + movieRecordId);
//                 }
//             } else {
//                 System.debug('No movie info found for TMDB ID: ' + tmdbId);
//             }
//         } catch (Exception e) {
//             System.debug('Error in fetchMovieDataAsync: ' + e.getMessage());
//         }
//     }
// }



public class tmdbFetchDataTriggerHandler {
    @future(callout=true)
    public static void fetchMovieDataAsync(List<String> tmdbIds, List<Id> movieRecordIds) {
        try {
            // Validate the input lists
            if (tmdbIds == null || movieRecordIds == null || tmdbIds.size() != movieRecordIds.size()) {
                throw new IllegalArgumentException('TMDB IDs and Movie Record IDs lists must be non-null and of equal length.');
            }

            // Fetch movie data for all TMDB IDs
            Map<String, tmdb.tmdbMovieResponse> tmdbIdToMovieInfoMap = new Map<String, tmdb.tmdbMovieResponse>();
            tmdb tmdbService = new tmdb();

            for (String tmdbId : tmdbIds) {
                tmdb.tmdbMovieResponse movieInfo = tmdbService.getMovieById(tmdbId);
                if (movieInfo != null) {
                    tmdbIdToMovieInfoMap.put(tmdbId, movieInfo);
                }
            }

            // Prepare updates for Movie__c records
            List<Movie__c> moviesToUpdate = new List<Movie__c>();

            for (Integer i = 0; i < tmdbIds.size(); i++) {
                String tmdbId = tmdbIds[i];
                Id movieRecordId = movieRecordIds[i];

                tmdb.tmdbMovieResponse movieInfo = tmdbIdToMovieInfoMap.get(tmdbId);

                if (movieInfo != null) {
                    Movie__c movieToUpdate = new Movie__c(Id = movieRecordId);
                    movieToUpdate.Description__c = movieInfo.overview;
                    movieToUpdate.Title__c = movieInfo.original_title;
                    movieToUpdate.Poster_URL__c = 'https://www.themoviedb.org/t/p/w600_and_h900_bestv2/' + movieInfo.poster_path;
                    movieToUpdate.Budget__c = movieInfo.budget;
                    movieToUpdate.Number__c = movieInfo.revenue;
                    movieToUpdate.Rating__c = movieInfo.vote_average;

                    moviesToUpdate.add(movieToUpdate);
                } else {
                    System.debug('No movie info found for TMDB ID: ' + tmdbId);
                }
            }

            // Update all Movie__c records in bulk
            if (!moviesToUpdate.isEmpty()) {
                update moviesToUpdate;
                System.debug('Records updated successfully: ' + moviesToUpdate);
            }

        } catch (Exception e) {
            System.debug('Error in fetchMovieDataAsync: ' + e.getMessage());
        }
    }
}