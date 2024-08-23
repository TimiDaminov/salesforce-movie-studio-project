@isTest
public class tmdbFetchDataTriggerTest {
    @isTest
    static void testTrigger() {
        Movie__c movie = new Movie__c();
        movie.Title__c = 'Test Movie';
        movie.tmdb_id__c = '12345';
        insert movie;
        
        Test.startTest();
        movie.Title__c = 'Updated Test Movie';
        update movie;
        Test.stopTest();

    }
}