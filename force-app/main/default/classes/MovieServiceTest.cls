@IsTest
public class MovieServiceTest {

    @IsTest
    static void testProcessMovies() {

        String jsonData = '[{' +
            '"id": "1",' +
            '"name": "Test Movie 1",' +
            '"tmdb_id": "tmdb12345",' +
            '"genre": "Action;Adventure",' +
            '"rating": 7.5,' +
            '"budget": 50000000,' +
            '"revenue": 100000000,' +
            '"script": {' +
                '"id": "script1",' +
                '"name": "Test Script 1",' +
                '"description": "Description of Test Script 1"' +
            '}' +
        '}, {' +
            '"id": "2",' +
            '"name": "Test Movie 2",' +
            '"tmdb_id": "tmdb67890",' +
            '"genre": "Comedy",' +
            '"rating": 6.8,' +
            '"budget": 30000000,' +
            '"revenue": 60000000,' +
            '"script": null' +
        '}]';


        Map<String, String> validGenres = new Map<String, String>{
            'action' => 'Action',
            'adventure' => 'Adventure',
            'comedy' => 'Comedy'
        };

        Script__c script = new Script__c(Name = 'Test Script 1', Description__c = 'Description of Test Script 1');
        insert script;

        Map<String, Script__c> scriptMap = new Map<String, Script__c>{
            'script1' => script
        };

        List<Movie__c> moviesToInsert = new List<Movie__c>();

        Test.startTest();
        MovieService.processMovies(jsonData, validGenres, scriptMap, moviesToInsert);
        Test.stopTest();
        List<Movie__c> insertedMovies = [SELECT Title__c, tmdb_id__c, Genre__c, Rating__c, Budget__c, Number__c, Script__c FROM Movie__c];
        System.assertEquals(2, insertedMovies.size(), 'There should be 2 movies inserted.');

        Movie__c movie1 = insertedMovies[0];
        System.assertEquals('Test Movie 1', movie1.Title__c, 'Title should match.');
        System.assertEquals('tmdb12345', movie1.tmdb_id__c, 'TMDB ID should match.');
        System.assertEquals('Action;Adventure', movie1.Genre__c, 'Genres should match.');
        System.assertEquals(7.5, movie1.Rating__c, 'Rating should match.');
        System.assertEquals(50000000, movie1.Budget__c, 'Budget should match.');
        System.assertEquals(100000000, movie1.Number__c, 'Revenue should match.');
        System.assertEquals(script.Id, movie1.Script__c, 'Script association should match.');

        Movie__c movie2 = insertedMovies[1];
        System.assertEquals('Test Movie 2', movie2.Title__c, 'Title should match.');
        System.assertEquals('tmdb67890', movie2.tmdb_id__c, 'TMDB ID should match.');
        System.assertEquals('Comedy', movie2.Genre__c, 'Genres should match.');
        System.assertEquals(6.8, movie2.Rating__c, 'Rating should match.');
        System.assertEquals(30000000, movie2.Budget__c, 'Budget should match.');
        System.assertEquals(60000000, movie2.Number__c, 'Revenue should match.');
        System.assertEquals(null, movie2.Script__c, 'Script association should be null.');
    }
}