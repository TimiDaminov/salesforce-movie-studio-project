public with sharing class MovieDataUploaderController {

    @AuraEnabled
    public static void parseAndCreateMovies(String contentDocumentId) {
        try {
            ContentVersion contentVersion = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId LIMIT 1];
            Blob fileBlob = contentVersion.VersionData;
            String jsonString = fileBlob.toString();

            List<JSONImporter.MovieData> jsonList = (List<JSONImporter.MovieData>) JSON.deserialize(jsonString, List<JSONImporter.MovieData>.class);
            List<Movie__c> movies = new List<Movie__c>();
            List<Script__c> scripts = new List<Script__c>();

            for (JSONImporter.MovieData movieData : jsonList) {
                if (movieData.script != null) {
                    JSONImporter.ScriptData scriptData = movieData.script;
                    Script__c script = new Script__c();
                    script.Name = scriptData.name;
                    script.Description__c = scriptData.description;
                    scripts.add(script);
                }
            }

            if (!scripts.isEmpty()) {
                insert scripts;
            }

            for (JSONImporter.MovieData movieData : jsonList) {
                Movie__c movie = new Movie__c();
                movie.Title__c = movieData.name;
                movie.TMDB_Id__c = movieData.tmdb_id;
                movie.Genre__c = movieData.genre;
                movie.Rating__c = movieData.rating != null ? movieData.rating : null;
                movie.Budget__c = movieData.budget != null ? movieData.budget : null;
                movie.Number__c = movieData.revenue != null ? movieData.revenue : null;

                if (movieData.script != null) {
                    JSONImporter.ScriptData scriptData = movieData.script;
                    for (Script__c script : scripts) {
                        if (script.Name == scriptData.name) {
                            movie.Script__c = script.Id;
                            break;
                        }
                    }
                }

                movies.add(movie);
            }

            insert movies;

        } catch (Exception e) {
            throw new AuraHandledException('Error ' + e.getMessage());
        }
    }
}
