
public with sharing class MovieTrailerController {
    private static final String API_KEY = '5bfef77f0d03fea766a8ab7ddfe11ab1';
    private static final String API_VERSION = '3';
    private static final String BASE_URL = 'https://api.themoviedb.org/';
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getMovieVideos(String tmdbId) {
        String resourceName = '/movie/' + tmdbId + '/videos';
        String endpoint = BASE_URL + API_VERSION + resourceName + '?api_key=' + API_KEY;
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        
        Http http = new Http();
        HttpResponse response;
        
        try {
            response = http.send(request);
            System.debug('Response Status: ' + response.getStatusCode());
            System.debug('Response Body: ' + response.getBody());
        } catch (Exception e) {
            System.debug('Error: ' + e.getMessage());
            return new List<Map<String, Object>>();
        }
        
        if (response.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('Response Map: ' + responseMap);
            
            if (responseMap.containsKey('results')) {
                Object resultsObject = responseMap.get('results');
                
                if (resultsObject instanceof List<Object>) {
                    List<Map<String, Object>> results = new List<Map<String, Object>>();
                    for (Object obj : (List<Object>) resultsObject) {
                        results.add((Map<String, Object>) obj);
                    }
                    return results;
                } else {
                    System.debug('Results are not a List: ' + resultsObject);
                }
            }
        }
        return new List<Map<String, Object>>();
    }

    @AuraEnabled(cacheable=true)
    public static Movie__c getMovieById(Id movieId) {
        return [SELECT Id, tmdb_id__c FROM Movie__c WHERE Id = :movieId LIMIT 1];
    }
}
