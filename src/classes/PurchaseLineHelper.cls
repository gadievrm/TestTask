public class PurchaseLineHelper {
	public static void updatePurchaseTotals(List<PurchaseLine__c> lines) {
		Set<Id> purchaseIds = new Set<Id>();
		for (PurchaseLine__c line : lines) {
			if (line.PurchaseId__c != null) {
				purchaseIds.add(line.PurchaseId__c);
			}
		}

		Map<Id, List<PurchaseLine__c>> linesByPurchase = new Map<Id, List<PurchaseLine__c>>();
		for (PurchaseLine__c pl : [
				SELECT PurchaseId__c, UnitCost__c, Amount__c
				FROM PurchaseLine__c
				WHERE PurchaseId__c IN :purchaseIds
		]) {
			if (!linesByPurchase.containsKey(pl.PurchaseId__c)) {
				linesByPurchase.put(pl.PurchaseId__c, new List<PurchaseLine__c>());
			}
			linesByPurchase.get(pl.PurchaseId__c).add(pl);
		}

		List<Purchase__c> updates = new List<Purchase__c>();

		for (Id purchaseId : linesByPurchase.keySet()) {
			List<PurchaseLine__c> plList = linesByPurchase.get(purchaseId);
			Integer totalItems = 0;
			Decimal grandTotal = 0;

			for (PurchaseLine__c line : plList) {
				totalItems += line.Amount__c == null ? 0 : Integer.valueOf(line.Amount__c);
				grandTotal += (line.UnitCost__c != null ? line.UnitCost__c : 0) * (line.Amount__c != null ? line.Amount__c : 0);
			}

			updates.add(new Purchase__c(
					Id = purchaseId,
					TotalItems__c = totalItems,
					GrandTotal__c = grandTotal
			));
		}

		if (!updates.isEmpty()) {
			update updates;
		}
	}
}
