public with sharing class PurchaseService {
	@AuraEnabled
	public static Id createPurchase(Id accountId, List<Id> itemIds) {
		if (accountId == null || itemIds == null || itemIds.isEmpty()) {
			throw new IllegalArgumentException ('Account and items are required.');
		}

		List<Item__c> items = [
				SELECT Id, Price__c
				FROM Item__c
				WHERE Id IN :itemIds
		];

		Decimal grandTotal = 0;
		List<PurchaseLine__c> lines = new List<PurchaseLine__c>();

		for (Item__c item : items) {
			grandTotal += item.Price__c;

			lines.add(new PurchaseLine__c(
					ItemId__c = item.Id,
					UnitCost__c = item.Price__c,
					Amount__c = 1
			));
		}

		Purchase__c purchase = new Purchase__c(
				ClientId__c = accountId,
				GrandTotal__c = grandTotal,
				TotalItems__c = items.size()
		);
		insert purchase;

		for (PurchaseLine__c line : lines) {
			line.PurchaseId__c = purchase.Id;
		}

		insert lines;

		return purchase.Id;
	}
}
