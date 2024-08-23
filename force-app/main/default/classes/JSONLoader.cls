public class JSONLoader {
    public static String loadJsonData(String resourceName) {
        StaticResource resource = [SELECT Body FROM StaticResource WHERE Name = :resourceName LIMIT 1];
        return resource.Body.toString();
    }
}