public with sharing class UnsplashService {
	private static final String ACCESS_KEY = 'F5UYgvLVW88IsXYkVXd7J2lL1IhDUJydCsV5s_WCWms';

	@AuraEnabled
	public static String fetchImageUrl(String query) {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint('https://api.unsplash.com/search/photos?query=' + EncodingUtil.urlEncode(query, 'UTF-8'));
		request.setMethod('GET');
		request.setHeader('Authorization', 'Client-ID ' + ACCESS_KEY);

		HttpResponse response = http.send(request);
		if (response.getStatusCode() == 200) {
			Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
			List<Object> photos = (List<Object>) result.get('results');
			if (!photos.isEmpty()) {
				Map<String, Object> photo = (Map<String, Object>) photos[0];
				Map<String, Object> urls = (Map<String, Object>) photo.get('urls');
				return (String) urls.get('small');
			}
		}
		return null;
	}
}