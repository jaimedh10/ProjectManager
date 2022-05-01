trigger ProjectTrigger on Project__c (after update) {
    new ProjectTriggerHandler().run();
}