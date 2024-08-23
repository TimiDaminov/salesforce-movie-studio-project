@IsTest
public class fetchMovieDataTest {
    
    @IsTest
    static void testFetchMovieDataAsync_Success() {

        Movie__c movie1 = new Movie__c(Title__c = 'Test Movie 1', tmdb_id__c = '101');
        Movie__c movie2 = new Movie__c(Title__c = 'Test Movie 2', tmdb_id__c = '102');
        insert new List<Movie__c> { movie1, movie2 };

        List<String> tmdbIds = new List<String> { '101', '102' };
        List<Id> movieRecordIds = new List<Id> { movie1.Id, movie2.Id };

        Test.setMock(HttpCalloutMock.class, new MockTmdbApiResponse());

        Test.startTest();
        fetchMovieData.fetchMovieDataAsync(tmdbIds, movieRecordIds);
        Test.stopTest();
        List<Movie__c> updatedMovies = [SELECT Id, Description__c, Title__c, Poster_URL__c, Budget__c, Rating__c, Number__c, TMDBSyncDate__c FROM Movie__c WHERE Id IN :movieRecordIds];

        System.assertEquals(2, updatedMovies.size(), 'Two movie records should be updated.');
        for (Movie__c movie : updatedMovies) {
            System.assertNotEquals(null, movie.Description__c, 'Description should not be null.');
            System.assertNotEquals(null, movie.Title__c, 'Title should be updated.');
            System.assertNotEquals(null, movie.Poster_URL__c, 'Poster URL should be set.');
            System.assertNotEquals(null, movie.Budget__c, 'Budget should be set.');
            System.assertNotEquals(null, movie.Rating__c, 'Rating should be set.');
            System.assertNotEquals(null, movie.Number__c, 'Revenue should be set.');
            System.assertEquals(Date.today(), movie.TMDBSyncDate__c, 'Sync date should be today.');
        }
    }
    
    @IsTest
    static void testFetchMovieDataAsync_NullLists() {
        List<String> tmdbIds = null;
        List<Id> movieRecordIds = null;
        Test.setMock(HttpCalloutMock.class, new MockTmdbApiResponse());

        Test.startTest();
        fetchMovieData.fetchMovieDataAsync(tmdbIds, movieRecordIds);
        Test.stopTest();
    }

    @IsTest
    static void testFetchMovieDataAsync_MismatchedLists() {
        Movie__c movie1 = new Movie__c(Title__c = 'Test Movie 1', tmdb_id__c = '101');
        insert movie1;

        List<String> tmdbIds = new List<String> { '101' };
        List<Id> movieRecordIds = new List<Id> { movie1.Id, Id.valueOf('000000000000000AAA') };

        Test.setMock(HttpCalloutMock.class, new MockTmdbApiResponse());

        Test.startTest();
        fetchMovieData.fetchMovieDataAsync(tmdbIds, movieRecordIds);
        Test.stopTest();
        List<Movie__c> updatedMovies = [SELECT Id, Description__c, Title__c, Poster_URL__c, Budget__c, Rating__c, Number__c, TMDBSyncDate__c FROM Movie__c WHERE Id = :movie1.Id];

        System.assertEquals(1, updatedMovies.size(), 'Only the valid movie record should be present.');
        Movie__c movie = updatedMovies[0];
        System.assertEquals(null, movie.Description__c, 'Description should be null.');
        System.assertEquals(null, movie.Title__c, 'Title should be null.');
        System.assertEquals(null, movie.Poster_URL__c, 'Poster URL should be null.');
        System.assertEquals(null, movie.Budget__c, 'Budget should be null.');
        System.assertEquals(null, movie.Rating__c, 'Rating should be null.');
        System.assertEquals(null, movie.Number__c, 'Revenue should be null.');
    }

    @IsTest
    static void testFetchMovieDataAsync_ExceptionHandling() {
        Movie__c movie1 = new Movie__c(Title__c = 'Test Movie 1', tmdb_id__c = '101');
        insert movie1;

        List<String> tmdbIds = new List<String> { '101' };
        List<Id> movieRecordIds = new List<Id> { movie1.Id };
        Test.setMock(HttpCalloutMock.class, new MockTmdbApiErrorResponse());

        Test.startTest();
        fetchMovieData.fetchMovieDataAsync(tmdbIds, movieRecordIds);
        Test.stopTest();
        List<Movie__c> updatedMovies = [SELECT Id, Description__c, Title__c, Poster_URL__c, Budget__c, Rating__c, Number__c, TMDBSyncDate__c FROM Movie__c WHERE Id = :movie1.Id];

        System.assertEquals(1, updatedMovies.size(), 'The movie record should still exist.');
        Movie__c movie = updatedMovies[0];
        System.assertEquals(null, movie.Description__c, 'Description should be null.');
        System.assertEquals(null, movie.Title__c, 'Title should be null.');
        System.assertEquals(null, movie.Poster_URL__c, 'Poster URL should be null.');
        System.assertEquals(null, movie.Budget__c, 'Budget should be null.');
        System.assertEquals(null, movie.Rating__c, 'Rating should be null.');
        System.assertEquals(null, movie.Number__c, 'Revenue should be null.');
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