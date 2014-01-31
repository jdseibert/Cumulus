public with sharing class ERR_Notifier {

    public static void sendEmailNotifications(ERR_Handler.Context context, String mailList) {
        if(context != null && context == ERR_Handler.Context.RD) {
            if (!system.isBatch() && !RD_ProcessControl.batchButton && !system.isFuture()) {
                sendErrorQueueEmailNotificationFuture(mailList);
            } else if (system.isFuture()){
                sendErrorQueueEmailNotification(mailList);
            }  
        }   
    }
    
    @future
    public static void sendErrorQueueEmailNotificationFuture(String mailList) { 
    	sendErrorQueueEmailNotification(mailList); 
    }
    
    public static void sendErrorQueueEmailNotification(String mailList) {
        map<Id, Error__c> rdeqMap = new Map<Id, Error__c>([select Id, Record_URL__c, Full_Message__c from Error__c]);
        
        if (!rdeqMap.isEmpty()){
            Messaging.SingleEmailMessage sme = createEmailMessage(rdeqMap.values(), mailList);
            if (!test.isRunningTest())
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{sme});
        }
        //clear the queue if not in a batch, otherwise, save them 
        if (!system.isBatch() && !RD_ProcessControl.batchButton)           
           delete [select id from Error__c];
    } 

    private static Messaging.SingleEmailMessage createEmailMessage(list<Error__c> rdeqList, String mailList) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setSenderDisplayName('Salesforce Recurring Donations');
        mail.setSubject('Salesforce Recurring Donations Errors');
        string bodyString = '';
        bodyString += system.label.npe03.RecurringDonationErrorEmailBody;
        bodyString += '\n\nErrors:';
        for (Error__c rdeq : rdeqlist){
            bodyString += '\n' + rdeq.Record_URL__c;
            bodystring += ' Error Message: ' + rdeq.Full_Message__c;           
        }        
        mail.setPlainTextBody(bodyString);
        list<string> sendList = new list<string>();
        
        //user, sysadmins or PG
        if (mailList.startsWith('005')) {
            sendList.add([select email from User where id = :mailList].email);
        } else if(mailList == 'All Sys Admins'){
            list<User> sysadminlist = [select email from User where User.Profile.Name = 'System Administrator'];
            for (User u : sysadminlist) {
                sendList.add(u.email);              
            }           
        } else if(mailList.startsWith('00G')) {
            list<GroupMember> groupUsers = [select g.UserOrGroupId from GroupMember g where GroupId = :mailList];
            set<id> userIDs = new set<id>();
            for (GroupMember g : groupUsers)
               userIDs.add(g.UserOrGroupId);
            list<User> userList = [select email from User where id IN :userIDs];
            for (User u : userList){
                sendList.add(u.email);
            }
        }        
        mail.setToAddresses(sendList);                   

        return mail;        
    }
    
    //@TODO
    public static void postErrorToChatter() {
    	
    }
    
    public static ErrorSettings getOrgSettings() {
        ErrorSettings errorSettings = new ErrorSettings();
        Error_Settings__c orgErrorSettings = Error_Settings__c.getOrgDefaults();
        errorSettings.storeErrors = orgErrorSettings.Store_Errors__c;
        errorSettings.sendEmailNotifications = orgErrorSettings.Email_Notifications__c;
        errorSettings.mailList = orgErrorSettings.Email_List__c;
        return errorSettings;
    }
    
    public class ErrorSettings {
        public Boolean storeErrors;
        public Boolean sendEmailNotifications;
        public String mailList;
    }
}