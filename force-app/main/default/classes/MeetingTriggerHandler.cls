public with sharing class MeetingTriggerHandler extends TriggerHandler {
    public Map<Id, Meeting__c> meetingOld;
    public Map<Id, Meeting__c> meetingNew;

    public override void afterUpdate() {
        this.meetingOld = (Map<Id, Meeting__c>) trigger.oldMap;
        this.meetingNew = (Map<Id, Meeting__c>) trigger.newMap;
        updateEventDate(this.meetingOld, this.meetingNew);
    }

    public override void afterInsert() {
        insertEvent(trigger.new);
    }

    // Método de inserção do Evento associado a um meeting e um projeto.
    private static void insertEvent(List<Meeting__c> meetingList) {
        
        
            List<Event> event = new List<Event>();
            Set<Id> project = new Set<Id>();

            for(Meeting__c m : meetingList) {
                project.add(m.Project__c);
            }
            Map<Id, Project__c> projectMap = new Map<Id, Project__c>([SELECT Id, Project_Manager__c FROM Project__c WHERE Id IN :project]);
            for(Meeting__c m : meetingList) {
                Event e = new Event();
                
                if(projectMap.containsKey(m.Project__c)) {
                    e.OwnerId = projectMap.get(m.Project__c).Project_Manager__c;
                    e.WhatId = projectMap.get(m.Project__c).Id;
                }
                else {
                    // notificação
                }
                e.Subject = 'Meeting';
                e.PMeeting__c = m.Id;     
                e.StartDateTime = m.Date__c;
                e.EndDateTime = m.Date__c;   
                event.add(e);
            }

            try {
                insert event;
            } catch (Exception e) {
                System.debug('Erro no update ' + e.getMessage() + ' na linha ' + e.getLineNumber());
            } 
    }

    // Método para atualizar data do evento
    private static void updateEventDate(Map<Id, Meeting__c> oldMeetingMap, Map<Id, Meeting__c> newMeetingMap) {

        Set<Id> meetingIdSet = new Set<Id>();
        
        for(Id id : oldMeetingMap.keySet()) {
            Meeting__c m = oldMeetingMap.get(id);
            Meeting__c newM = newMeetingMap.get(id);
            if(m.Date__c != newM.Date__c) {
                meetingIdSet.add(id);
            }
        }

        List<Event> eventList = [SELECT PMeeting__c FROM Event WHERE PMeeting__c IN :meetingIdSet];

        for(Event e : eventList) {
            e.StartDateTime = newMeetingMap.get(e.PMeeting__c).Date__c;
            e.EndDateTime = newMeetingMap.get(e.PMeeting__c).Date__c;
        }
            
        try {
            if(!eventList.isEmpty()) {
                update eventList;
            }
        } catch (Exception e) {
            System.debug('Erro no update ' + e.getMessage() + ' na linha ' + e.getLineNumber());
        } 
    }  
}
