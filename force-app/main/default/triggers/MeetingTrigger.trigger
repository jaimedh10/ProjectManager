trigger MeetingTrigger on Meeting__c (after insert, after update) {
    new MeetingTriggerHandler().run();
}