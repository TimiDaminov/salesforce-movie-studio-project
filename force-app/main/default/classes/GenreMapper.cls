public class GenreMapper {
    public static Map<String, String> getValidGenres() {
        Map<String, String> validGenres = new Map<String, String>();
        Schema.DescribeFieldResult genreField = Movie__c.Genre__c.getDescribe();
        for (Schema.PicklistEntry entry : genreField.getPicklistValues()) {
            validGenres.put(entry.getLabel().toLowerCase(), entry.getValue());
        }
        return validGenres;
    }

    public static String mapGenres(String genreString, Map<String, String> validGenres) {
        List<String> genres = genreString.split(';');
        List<String> mappedGenres = new List<String>();
        for (String genre : genres) {
            String lowerGenre = genre.toLowerCase();
            if (validGenres.containsKey(lowerGenre)) {
                mappedGenres.add(validGenres.get(lowerGenre));
            } else {
                System.debug('Genre "' + genre + '" is not valid for the Genre__c picklist and will be ignored.');
            }
        }
        return String.join(mappedGenres, ';');
    }
}