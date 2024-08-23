public class TMDBSyncBatchScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        TMDBSyncBatch batchJob = new TMDBSyncBatch();
        Database.executeBatch(batchJob);
    }
}