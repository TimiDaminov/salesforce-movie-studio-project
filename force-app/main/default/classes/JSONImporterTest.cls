@IsTest
public class JSONImporterTest {
    @IsTest
    static void testParseAndCreateMovies() {
        String jsonData = '[{ "id": "1", "name": "Movie 1", "tmdb_id": "101", "genre": "Action;Drama", "rating": 8.5, "budget": 100000, "revenue": 500000, "script": { "id": "1", "name": "Script 1", "description": "A thrilling movie script." }, "release_date": "2024-08-14", "status": "Released" }]';

        Test.startTest();
        JSONImporter.parseAndCreateMovies();
        Test.stopTest();
        List<Movie__c> movies = [SELECT Title__c, tmdb_id__c, Genre__c, Rating__c, Budget__c, Number__c, Script__c FROM Movie__c];
        System.assertEquals(1, movies.size());
        System.assertEquals('Movie 1', movies[0].Title__c);
        System.assertEquals('101', movies[0].tmdb_id__c);
        System.assertEquals('Action;Drama', movies[0].Genre__c);
        System.assertEquals(8.5, movies[0].Rating__c);
        System.assertEquals(100000, movies[0].Budget__c);
        System.assertEquals(500000, movies[0].Number__c);
        System.assertNotEquals(null, movies[0].Script__c);


        List<Script__c> scripts = [SELECT Name, Description__c FROM Script__c];
        System.assertEquals(1, scripts.size());
        System.assertEquals('Script 1', scripts[0].Name);
        System.assertEquals('A thrilling movie script.', scripts[0].Description__c);
    }


}