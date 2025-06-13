@isTest
private class PurchaseServiceTest {

	@testSetup
	static void setupData() {
		Account acc = new Account(Name = 'Test Account', Industry = 'Tech');
		insert acc;

		List<Item__c> items = new List<Item__c>{
				new Item__c(Name = 'Item A', Price__c = 100),
				new Item__c(Name = 'Item B', Price__c = 200)
				};
		insert items;
	}

	@isTest
	static void testCreatePurchase() {
		Account acc = [SELECT Id FROM Account LIMIT 1];
		List<Item__c> items = [SELECT Id FROM Item__c];

		Test.startTest();
		Id purchaseId = PurchaseService.createPurchase(acc.Id, new List<Id>{
				items[0].Id,
				items[1].Id
				});
		Test.stopTest();

		Purchase__c purchase = [
				SELECT TotalItems__c, GrandTotal__c
				FROM Purchase__c
				WHERE Id = :purchaseId
		];

		System.assertEquals(2, purchase.TotalItems__c, 'Should have 2 items');
		System.assertEquals(300, purchase.GrandTotal__c, 'Should total 300 USD');

		List<PurchaseLine__c> lines = [
				SELECT Id FROM PurchaseLine__c WHERE PurchaseId__c = :purchaseId
		];
		System.assertEquals(2, lines.size(), 'Should have 2 lines');
	}

	@isTest
	static void testNullInputThrowsError() {
		try {
			PurchaseService.createPurchase(null, new List<Id>());
			System.assert(false, 'Expected AuraHandledException');
		} catch (AuraHandledException e) {
			System.assert(e.getMessage().contains('Account and items are required'));
		}
	}
}
