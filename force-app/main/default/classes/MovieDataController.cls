public with sharing class MovieDataController {

    @AuraEnabled(cacheable=true)
    public static String getMovieTitle(Id recordId) {
        Movie__c movie = [SELECT Title__c FROM Movie__c WHERE Id = :recordId LIMIT 1];
        return movie != null ? movie.Title__c : null;
    }
}