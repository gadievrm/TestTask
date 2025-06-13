trigger PurchaseLineTrigger on PurchaseLine__c (after insert, after delete, after update) {
	if (Trigger.isAfter) {
		if (Trigger.isInsert || Trigger.isDelete || Trigger.isUpdate) {
			PurchaseLineHelper.updatePurchaseTotals(Trigger.isDelete ? Trigger.old : Trigger.new);
		}
	}
}
