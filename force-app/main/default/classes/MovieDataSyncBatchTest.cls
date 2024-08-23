@IsTest
public class MovieDataSyncBatchTest {

    @IsTest
    static void testBatchProcessing() {
        Movie__c movie1 = new Movie__c(
            Title__c = 'Old Movie 1',
            tmdb_id__c = '101'
        );
        Movie__c movie2 = new Movie__c(
            Title__c = 'Old Movie 2',
            tmdb_id__c = '102'
        );
        insert new List<Movie__c> { movie1, movie2 };

        Test.setMock(HttpCalloutMock.class, new MockTmdbApiResponse());

        Test.startTest();
        Database.executeBatch(new MovieDataSyncBatch(), 1);
        Test.stopTest();

        List<Movie__c> updatedMovies = [SELECT Id, Title__c, Description__c, Budget__c, Rating__c, Number__c, TMDBSyncDate__c FROM Movie__c WHERE Id IN :new List<Id>{movie1.Id, movie2.Id}];

        System.assertEquals(2, updatedMovies.size(), 'Two movie records should be updated.');
        for (Movie__c movie : updatedMovies) {
            System.assertEquals('Test Original Title', movie.Title__c, 'Title should be updated.');
            System.assertEquals('Test overview', movie.Description__c, 'Description should be updated.');
            System.assertEquals(100000, movie.Budget__c, 'Budget should be updated.');
            System.assertEquals(8.5, movie.Rating__c, 'Rating should be updated.');
            System.assertEquals(500000, movie.Number__c, 'Revenue should be updated.');
            System.assertEquals(Date.today(), movie.TMDBSyncDate__c, 'TMDBSyncDate__c should be set to today.');
        }
    }

    @IsTest
    static void testBatchProcessing_NoRecordsToProcess() {
        Movie__c movie1 = new Movie__c(
            Title__c = 'Recent Movie',
            TMDBSyncDate__c = Date.today(),
            tmdb_id__c = '101'
        );
        insert movie1;

        Test.setMock(HttpCalloutMock.class, new MockTmdbApiResponse());

        Test.startTest();
        Database.executeBatch(new MovieDataSyncBatch(), 1);
        Test.stopTest();

        List<Movie__c> movies = [SELECT Id, Title__c, Description__c, Budget__c, Rating__c, Number__c, TMDBSyncDate__c FROM Movie__c WHERE Id = :movie1.Id];
        System.assertEquals(1, movies.size(), 'Movie record should exist.');
        Movie__c movie = movies[0];
        System.assertEquals('Recent Movie', movie.Title__c, 'Title should remain unchanged.');
        System.assertEquals(Date.today(), movie.TMDBSyncDate__c, 'TMDBSyncDate__c should remain unchanged.');
    }

    @IsTest
    static void testBatchProcessing_ErrorHandling() {
        Movie__c movie1 = new Movie__c(
            Title__c = 'Error Movie',
            tmdb_id__c = '101'
        );
        insert movie1;

        Test.setMock(HttpCalloutMock.class, new MockTmdbApiErrorResponse());

        Test.startTest();
        Database.executeBatch(new MovieDataSyncBatch(), 1);
        Test.stopTest();

        List<Movie__c> updatedMovies = [SELECT Id, Title__c, Description__c, Budget__c, Rating__c, Number__c, TMDBSyncDate__c FROM Movie__c WHERE Id = :movie1.Id];

        System.assertEquals(1, updatedMovies.size(), 'Movie record should exist.');
        Movie__c movie = updatedMovies[0];
        System.assertEquals('Error Movie', movie.Title__c, 'Title should remain unchanged.');
        System.assertEquals(null, movie.Description__c, 'Description should be null.');
        System.assertEquals(null, movie.Budget__c, 'Budget should be null.');
        System.assertEquals(null, movie.Rating__c, 'Rating should be null.');
        System.assertEquals(null, movie.Number__c, 'Revenue should be null.');
        System.assertNotEquals(Date.today(), movie.TMDBSyncDate__c, 'TMDBSyncDate__c should not be updated.');
    }

    private class MockTmdbApiResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"overview": "Test overview", "original_title": "Test Original Title", "revenue": 500000, "vote_average": 8.5, "poster_path": "/testpath.jpg", "budget": 100000}');
            return res;
        }
    }

    private class MockTmdbApiErrorResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"status_code": 34, "status_message": "The resource you requested could not be found."}');
            return res;
        }
    }
}