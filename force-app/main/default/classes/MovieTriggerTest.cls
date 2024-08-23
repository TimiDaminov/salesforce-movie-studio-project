@IsTest
public class MovieTriggerTest {

    @IsTest
    static void testMovieTrigger() {
        
        Movie__c movie1 = new Movie__c(
            tmdb_id__c = 'tmdb12345',
            Title__c = 'Test Movie 1 Title',
            Genre__c = 'Action',
            Rating__c = 8.0,
            Budget__c = 50000000,
            Number__c = 100000000
        );
        
        Movie__c movie2 = new Movie__c(
            tmdb_id__c = 'tmdb67890',
            Title__c = 'Test Movie 2 Title',
            Genre__c = 'Comedy',
            Rating__c = 6.5,
            Budget__c = 30000000,
            Number__c = 60000000
        );

        Test.startTest();
        insert new List<Movie__c>{movie1, movie2};
        Test.stopTest();
        List<AsyncApexJob> asyncJobs = [SELECT Id, Status FROM AsyncApexJob WHERE JobType = 'Future' AND ApexClass.Name = 'fetchMovieData'];
        System.assertEquals(1, asyncJobs.size(), 'There should be exactly one future job for fetchMovieDataAsync.');
    }
}