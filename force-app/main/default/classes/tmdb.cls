public with sharing class tmdb {
    private static final String API_KEY = '5bfef77f0d03fea766a8ab7ddfe11ab1';
    private static final String API_KEY_PARAM_NAME = 'api_key';
    private static final String API_VERSION = '3';
    private static final String BASE_URL = 'https://api.themoviedb.org/';

    private String buildResourceUrl(String resourceName) {
        return BASE_URL + API_VERSION + resourceName;
    }

    private HttpRequest authenticateRequest(HttpRequest request) {
        String endpoint = request.getEndpoint();
        if (endpoint.contains('?')) {
            endpoint += '&' + API_KEY_PARAM_NAME + '=' + API_KEY;
        } else {
            endpoint += '?' + API_KEY_PARAM_NAME + '=' + API_KEY;
        }
        request.setEndpoint(endpoint);
        return request;
    }

    public tmdbSearchMovieResponse searchMovie(String title) {
        String resourceName = '/search/movie';
        String endpoint = buildResourceUrl(resourceName);
        endpoint += '?query=' + EncodingUtil.urlEncode(title, 'UTF-8');
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint);
        request = authenticateRequest(request);
        

        
        Http http = new Http();
        HttpResponse response = http.send(request);

        // Debugging response for troubleshooting
        System.debug(response.getBody());
        return (tmdbSearchMovieResponse) JSON.deserialize(response.getBody(), tmdbSearchMovieResponse.class);
    }

    public tmdbMovieResponse getMovieById(String movieId) {
        String resourceName = '/movie/' + movieId + '?language=en-US';
        String endpoint = buildResourceUrl(resourceName);
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint);
        request = authenticateRequest(request);
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug('Response Body: ' + response.getBody());
        tmdbMovieResponse movieData = (tmdbMovieResponse) JSON.deserialize(response.getBody(), tmdbMovieResponse.class);
        return movieData;
    }

    public tmdbGenreListResponse genreList() {
        String resourceName = '/genre/movie/list';
        String endpoint = buildResourceUrl(resourceName);
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(endpoint);
        request = authenticateRequest(request);
        

        Http http = new Http();
        HttpResponse response = http.send(request);
        return (tmdbGenreListResponse) JSON.deserialize(response.getBody(), tmdbGenreListResponse.class);
    }

    
    public class tmdbMovieResponse {
        public String overview;
        public String original_title;
        public Long revenue;
        public Double vote_average;
        public String poster_path;
        public Long budget;
        public List<tmdbGenre> genres;
    }
}
