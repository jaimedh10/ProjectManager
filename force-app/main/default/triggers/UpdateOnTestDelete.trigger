trigger UpdateOnTestDelete on Test__c (after delete) {
    new TestTriggerHandler().run();
}