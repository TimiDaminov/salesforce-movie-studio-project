public with sharing class MovieCatalogController {
    @AuraEnabled(cacheable=true)
    public static List<String> getGenres() {
        List<String> genreOptions = new List<String>();
        for (Schema.PicklistEntry entry : Schema.SObjectType.Movie__c.fields.Genre__c.getPicklistValues()) {
            genreOptions.add(entry.getValue());
        }
        return genreOptions;
    }

    @AuraEnabled(cacheable=true)
    public static List<Movie__c> getMovies() {
        return [SELECT Id, Title__c, Rating__c, Genre__c, Poster_URL__c FROM Movie__c];
    }
}
