@isTest
private class AccountServiceTest {

	@isTest
	static void testGetAccountById() {
		Account acc = new Account(Name = 'Test Account', AccountNumber = '34234123rtygf4ertg2', Industry = 'Tech');
		insert acc;

		Test.startTest();
		Account result = AccountService.getAccountById(acc.Id);
		Test.stopTest();

		System.assertEquals(acc.Id, result.Id);
		System.assertEquals('34234123rtygf4ertg2', result.AccountNumber);
		System.assertEquals('Tech', result.Industry);
	}

	@isTest
	static void testThrowsWhenIdIsNull() {
		Boolean didThrow = false;

		try {
			AccountService.getAccountById(null);
		} catch (IllegalArgumentException e) {
			didThrow = true;
			System.assert(e.getMessage().contains('Account Id is required'));
		}

		System.assertEquals(true, didThrow, 'Exception was expected but not thrown');
	}
}
