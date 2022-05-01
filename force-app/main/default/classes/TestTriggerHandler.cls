public with sharing class TestTriggerHandler extends TriggerHandler {
    
    public override void afterDelete() {
        updateReqTestTotal(trigger.old);
        updateReqCompletedTestsTotal(trigger.old);
    }

    // Método de atualização do número de testes associados a um requisito
    private static void updateReqTestTotal(List<Test__c> tl) {
       Set<Id> reqIds = new Set<Id>();

       for(Test__c t : tl) {
           reqIds.add(t.Requirement__c);
       }

       List<Test__c> currentTests = [SELECT Id, Requirement__c FROM Test__c WHERE Requirement__c IN :reqIds];
       
       Map<Id,Integer> reqTotal = new Map<Id,Integer>();
       for(Test__c cT : currentTests) {
            if(reqTotal.containsKey(cT.Requirement__c)){
                reqTotal.put(cT.Requirement__c, reqTotal.get(cT.Requirement__c)+1);
            }
            else {
                reqTotal.put(cT.Requirement__c, 1);
            }
       }

       List<Requirement__c> reqList = [SELECT Id, Number_Of_Tests__c FROM Requirement__c WHERE Id IN :reqIds];
       for (Requirement__c r : reqList) {
           r.Number_Of_Tests__c = reqTotal.get(r.Id);
       }

       try {
           update reqList;
       } catch (Exception e) {
           System.debug('Erro no update ' + e.getMessage() + ' na linha ' + e.getLineNumber());
       }
    }

    // Método de atualização do número de testes completos de um requisito
    private static void updateReqCompletedTestsTotal(List<Test__c> tl) {
        Set<Id> reqIds = new Set<Id>();

        for(Test__c t : tl) {
            reqIds.add(t.Requirement__c);
        }

        List<Test__c> currentTests = [SELECT Id, Requirement__c FROM Test__c WHERE Status__c = 'Done' AND Requirement__c IN :reqIds];
        
        Map<Id,Integer> reqTotal = new Map<Id,Integer>();
        for(Test__c cT : currentTests) {
            if(reqTotal.containsKey(cT.Requirement__c)){
                reqTotal.put(cT.Requirement__c, reqTotal.get(cT.Requirement__c)+1);
            }
            else {
                reqTotal.put(cT.Requirement__c, 1);
            }
        }

        List<Requirement__c> reqList = [SELECT Id, Number_Of_Tests__c FROM Requirement__c WHERE Id IN :reqIds];
        for (Requirement__c r : reqList) {
            r.Total_Of_Tests_Completed__c = reqTotal.get(r.Id);
        }

        try {
            update reqList;
        } catch (Exception e) {
            System.debug('Erro no update ' + e.getMessage() + ' na linha ' + e.getLineNumber());
        }
    }   
}
