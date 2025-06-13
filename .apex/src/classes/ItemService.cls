public with sharing class ItemService {
	@AuraEnabled(cacheable=true)
	public static List<Item__c> getItems() {
		return [
				SELECT Id, Name, Description__c, Type__c, Family__c, Price__c, Image__c
				FROM Item__c
				LIMIT 50
		];
	}
}
