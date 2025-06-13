public with sharing class AccountService {
	@AuraEnabled(cacheable=true)
	public static Account getAccountById(Id accountId) {
		if (accountId == null) {
			throw new AuraHandledException('Account Id is required');
		}

		return [
				SELECT Id, Name, AccountNumber, Industry
				FROM Account
				WHERE Id = :accountId
				LIMIT 1
		];
	}
}