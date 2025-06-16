@isTest
global class UnsplashServiceMock implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setStatusCode(200);
		res.setBody(
						'{' +
						'"results": [' +
						'{' +
						'"urls": {' +
						'"small": "https://images.unsplash.com/test-image"' +
						'}' +
						'}' +
						']' +
						'}'
		);
		return res;
	}
}
