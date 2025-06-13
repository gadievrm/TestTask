@isTest
private class ItemServiceTest {

	@isTest
	static void testGetItemsReturnsData() {
		insert new Item__c(
				Name = 'Test Item',
				Description__c = 'For testing',
				Type__c = 'New',
				Family__c = 'Electronics',
				Price__c = 99.99,
				Image__c = 'https://example.com/image.jpg'
		);

		Test.startTest();
		List<Item__c> items = ItemService.getItems();
		Test.stopTest();

		System.assert(!items.isEmpty(), 'Should return at least one item');
		System.assertEquals('Test Item', items[0].Name);
	}
}
