@isTest
public with sharing class OpportunityLineItemReschedulerTest {
    
    static TestMethod void unitTest1() {

        Account acc1 = new Account(Name = 'Test Account');
        insert acc1;
        System.assertNotEquals(null,acc1.id);
        
        Opportunity opp1 = new Opportunity(Name = 'Test Opp', AccountId = acc1.Id, StageName = 'Closed Won',CloseDate = System.today());
        insert opp1;
        System.assertNotEquals(null,opp1.id);
        
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true,
            CanUseRevenueSchedule = true,
            RevenueScheduleType = 'Repeat',
            RevenueInstallmentPeriod = 'Monthly',
            NumberOfRevenueInstallments = 12
        );
        insert prod;
        System.assertNotEquals(null,prod.id);
        
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        System.assertNotEquals(null,pbEntry.id);
        
        
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp1.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            TotalPrice = 10 * pbEntry.UnitPrice
        );
        insert oli;
        System.assertNotEquals(null,oli.id);
    }
}