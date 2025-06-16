@isTest
private class UnsplashServiceTest {

	@isTest
	static void testFetchImageUrlReturnsMockedUrl() {
		Test.setMock(HttpCalloutMock.class, new UnsplashServiceMock());

		Test.startTest();
		String url = UnsplashService.fetchImageUrl('nature');
		Test.stopTest();

		System.assertNotEquals(null, url, 'URL should not be null');
		System.assert(url.contains('unsplash.com'), 'URL should point to Unsplash');
	}

	@isTest
	static void testReturnsNullIfEmptyResults() {
		Test.setMock(HttpCalloutMock.class, new EmptyUnsplashMock());

		Test.startTest();
		String url = UnsplashService.fetchImageUrl('nonsensequery');
		Test.stopTest();

		System.assertEquals(null, url, 'Should return null if no results');
	}
}
