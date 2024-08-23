public class JSONImporter {
    public class MovieData {
        public String id;
        public String name;
        public String tmdb_id;
        public String genre;
        public Decimal rating;
        public Long budget;
        public Long revenue;
        public ScriptData script;
        public String release_date;
        public String status;
    }

    public class ScriptData {
        public String id;
        public String name;
        public String description;
    }

    public static void parseAndCreateMovies() {
        String jsonData = JSONLoader.loadJsonData('movies');
        Map<String, String> validGenres = GenreMapper.getValidGenres();
        List<Movie__c> moviesToInsert = new List<Movie__c>();
        List<Script__c> scriptsToInsert = new List<Script__c>();
        Map<String, Script__c> scriptMap = new Map<String, Script__c>();
        ScriptService.processScripts(jsonData, scriptMap, scriptsToInsert);
        ScriptService.insertScripts(scriptsToInsert, scriptMap);
        MovieService.processMovies(jsonData, validGenres, scriptMap, moviesToInsert);

        if (!moviesToInsert.isEmpty()) {
            insert moviesToInsert;
        }
    }
}