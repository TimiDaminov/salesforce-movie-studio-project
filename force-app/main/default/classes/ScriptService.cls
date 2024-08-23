public class ScriptService {
    public static void processScripts(String jsonData, Map<String, Script__c> scriptMap, List<Script__c> scriptsToInsert) {
        JSONParser parser = JSON.createParser(jsonData);
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                JSONImporter.MovieData movieData = (JSONImporter.MovieData)parser.readValueAs(JSONImporter.MovieData.class);

                if (movieData.script != null && !scriptMap.containsKey(movieData.script.id)) {
                    String scriptName = movieData.script.name;
                    scriptName = truncateString(scriptName, 80);

                    Script__c script = new Script__c(Name = scriptName, Description__c = movieData.script.description);
                    scriptsToInsert.add(script);
                    scriptMap.put(movieData.script.id, script);
                }
            }
        }
    }

    public static void insertScripts(List<Script__c> scriptsToInsert, Map<String, Script__c> scriptMap) {
        if (!scriptsToInsert.isEmpty()) {
            insert scriptsToInsert;
            for (Script__c script : scriptsToInsert) {
                scriptMap.put(script.Name, script);
            }
        }
    }

    private static String truncateString(String str, Integer maxLength) {
        return str.length() > maxLength ? str.substring(0, maxLength) : str;
    }
}