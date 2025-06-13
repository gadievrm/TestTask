@isTest
private class PurchaseLineHelperTest {

	@isTest
	static void testUpdatePurchaseTotals() {

		Account acc = new Account(Name = 'Client');
		insert acc;

		Purchase__c purchase = new Purchase__c(ClientId__c = acc.Id);
		insert purchase;

		Item__c item1 = new Item__c(Name = 'Item 1', Price__c = 50);
		Item__c item2 = new Item__c(Name = 'Item 2', Price__c = 100);
		insert new List<Item__c>{ item1, item2 };

		List<PurchaseLine__c> lines = new List<PurchaseLine__c>{
				new PurchaseLine__c(PurchaseId__c = purchase.Id, ItemId__c = item1.Id, UnitCost__c = 50, Amount__c = 2),
				new PurchaseLine__c(PurchaseId__c = purchase.Id, ItemId__c = item2.Id, UnitCost__c = 100, Amount__c = 1)
				};
		insert lines;


		Test.startTest();
		PurchaseLineHelper.updatePurchaseTotals(lines);
		Test.stopTest();


		purchase = [SELECT TotalItems__c, GrandTotal__c FROM Purchase__c WHERE Id = :purchase.Id];

		System.assertEquals(3, purchase.TotalItems__c, '2 + 1 items = 3');
		System.assertEquals(200, purchase.GrandTotal__c, '50*2 + 100*1 = 200');
	}
}
