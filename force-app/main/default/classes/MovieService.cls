public class MovieService {
    public static void processMovies(String jsonData, Map<String, String> validGenres, Map<String, Script__c> scriptMap, List<Movie__c> moviesToInsert) {
        JSONParser parser = JSON.createParser(jsonData);
        Integer chunkSize = 100;

        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                JSONImporter.MovieData movieData = (JSONImporter.MovieData)parser.readValueAs(JSONImporter.MovieData.class);

                Movie__c movie = new Movie__c();
                movie.Title__c = movieData.name;
                movie.tmdb_id__c = movieData.tmdb_id;
                movie.Genre__c = GenreMapper.mapGenres(movieData.genre, validGenres);
                movie.Rating__c = movieData.rating;
                movie.Budget__c = movieData.budget;
                movie.Number__c = movieData.revenue;

                if (movieData.script != null && scriptMap.containsKey(movieData.script.id)) {
                    movie.Script__c = scriptMap.get(movieData.script.id).Id;
                }

                moviesToInsert.add(movie);

                if (moviesToInsert.size() == chunkSize) {
                    insert moviesToInsert;
                    moviesToInsert.clear();
                }
            }
        }
    }
}