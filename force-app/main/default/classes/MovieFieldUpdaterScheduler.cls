public class MovieFieldUpdaterScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        // Instantiate the batch class
        MovieFieldUpdater batch = new MovieFieldUpdater();

        // Execute the batch class with the defined batch size
        Database.executeBatch(batch, MovieFieldUpdater.BATCH_SIZE);
    }
}