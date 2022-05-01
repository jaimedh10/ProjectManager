public with sharing class ProjectTriggerHandler extends TriggerHandler {
    public Map<Id,Project__c> project;

    public override void afterUpdate() {
        this.project = (Map<Id, Project__c>) trigger.newMap;
        updatePMEvent(this.project);
    }

    // Método de alteração do GP do evento
    private static void updatePMEvent(Map<Id, Project__c> projectMap) {
        
        List<Event> eventList = [SELECT WhatId, OwnerId FROM Event WHERE WhatId IN :projectMap.keySet()];

        for(Event e : eventList) {
            e.OwnerId = projectMap.get(e.WhatId).Project_Manager__c;
        }

        try {
            update eventList;
        } catch (Exception e) {
            System.debug('Erro no update ' + e.getMessage() + ' na linha ' + e.getLineNumber());
        }
    }
}
