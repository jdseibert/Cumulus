/*
    Copyright (c) 2009, Salesforce.com Foundation
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
 
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.com Foundation
* @date 2011 (1.x)
* @description CAO_Constants for use in IndividualAccounts.cls 
*/
global with sharing class CAO_Constants {
    //One-to-One value for system processor field
    global static final String ONE_TO_ONE_PROCESSOR = 'One-to-One';
    //One-to-One org type value
    global static final String ONE_TO_ONE_ORGANIZATION_TYPE = 'One-to-One Individual';
    
    //Bucket value for system processor field
    global static final String BUCKET_PROCESSOR = 'Individual';
    //Buck org type value
    global static final String BUCKET_ORGANIZATION_TYPE = 'Bucket Individual';
    //Bucket Account name
    global static  String BUCKET_ACCOUNT_NAME = 'Individual';
    
    //HH_Account value for system processor field
    global static final String HH_ACCOUNT_PROCESSOR = 'HH Account';
    //HH_Account type value
    global static final String HH_ACCOUNT_TYPE = 'HH Account';

    global static npe01__Contacts_and_Orgs_Settings__c ContactsSettings;
    
    global static  string CONTACT_FIRSTNAME_FOR_TESTS = 'test';
    global static  string CONTACT_LASTNAME_FOR_TESTS = 'Contact_forTests';
    
    global static  string CONTACT_EMAIL_FOR_TESTS = 'junk@test.net';
    global static  string CONTACT_PREFERRED_EMAIL_FOR_TESTS = 'Work';
    global static  string CONTACT_PHONE_FOR_TESTS = '206-777-8888';
    global static  string CONTACT_PREFERRED_PHONE_FOR_TESTS = 'Work';
    
    global static  string INDIVIDUAL_ACCOUNT_NAME_FOR_TESTS = 'IndividualAccountNameForTests';
    
    
    
    //get the settings. handles the case where the managed value doesn't exist yet
    global static npe01__Contacts_and_Orgs_Settings__c getContactsSettings() {
        boolean usedToBeOneToOne = false;
        boolean usedToBeBucket = false;
        //if no settings exist, create defaults
        if (ContactsSettings == null) {
            //first see if we already have settings
            ContactsSettings = npe01__Contacts_and_Orgs_Settings__c.getOrgDefaults();
            //system.debug(npe01__Contacts_and_Orgs_Settings__c.getOrgDefaults());
            
            if (ContactsSettings.Id == null) { 
                //get the model they used to be in 
                Schema.DescribeFieldResult F = Schema.sObjectType.Contact.fields.npe01__SystemAccountProcessor__c; 
                List<Schema.PicklistEntry> P = F.getPicklistValues();
                
                for(Schema.PicklistEntry pe : P) {
                    if (pe.isDefaultValue()) {
                        if (pe.getValue()==CAO_Constants.ONE_TO_ONE_PROCESSOR) {
                            usedToBeOneToOne = true;
                            break;
                        }
                        if (pe.getValue()==CAO_Constants.BUCKET_PROCESSOR) {
                            usedToBeBucket = true;
                            break;
                        }                        
                    }
                }

                //ContactsSettings = new npe01__Contacts_and_Orgs_Settings__c();

                //set them up with their old setting in the new settings object
                if (usedToBeOneToOne) {
                    ContactsSettings.npe01__Account_Processor__c = ONE_TO_ONE_PROCESSOR;
                } else if (usedToBeBucket) {
                    ContactsSettings.npe01__Account_Processor__c = BUCKET_PROCESSOR;
                } else {
                    ContactsSettings.npe01__Account_Processor__c = HH_ACCOUNT_PROCESSOR;                	
                }
                
                //set the other settings to reasonable defaults
                ContactsSettings.npe01__Enable_Opportunity_Contact_Role_Trigger__c = false;
                ContactsSettings.npe01__Payments_Enabled__c  = true;
                //ContactsSettings.npe01__Opportunity_Contact_Role_Default_role__c = 'Donor';
                ContactsSettings.Setupownerid = UserInfo.getOrganizationId();
                //this is not allowed...
                insert ContactsSettings;
            }
        }
        return ContactsSettings;
    }
    
    global static npe01__Contacts_and_Orgs_Settings__c getContactsSettingsForTests(npe01__Contacts_and_Orgs_Settings__c mySettings) {
        
        //clear out whatever settings exist
        delete [select id from npe01__Contacts_and_Orgs_Settings__c];
        
        //create our own based on what's passed in from the test 
        ContactsSettings = new npe01__Contacts_and_Orgs_Settings__c (
            npe01__One_to_One_RecordTypeID__c = mySettings.npe01__One_to_One_RecordTypeID__c, 
            npe01__HH_Account_RecordTypeID__c = mySettings.npe01__HH_Account_RecordTypeID__c,
            npe01__Account_Processor__c = mySettings.npe01__Account_Processor__c,
            npe01__Enable_Opportunity_Contact_Role_Trigger__c = mySettings.npe01__Enable_Opportunity_Contact_Role_Trigger__c,
            npe01__Opportunity_Contact_Role_Default_role__c = mySettings.npe01__Opportunity_Contact_Role_Default_role__c,
            npe01__Disable_Account_Model_Trigger__c = mySettings.npe01__Disable_Account_Model_Trigger__c,
            npe01__Payments_Enabled__c = mySettings.npe01__Payments_Enabled__c
            );
        insert ContactsSettings;
        return ContactsSettings;
    }

    /*
     //method to tell which model we're currently in for Accounts
    public static boolean isOneToOne() {
        boolean isOneToOneModel;
        isOneToOneModel = false;
        Schema.DescribeFieldResult F = Schema.sObjectType.Contact.fields.npe01__npe01__SystemAccountProcessor__c; 
        List<Schema.PicklistEntry> P = F.getPicklistValues();
        for(Schema.PicklistEntry pe : P){
            if (pe.isDefaultValue()){
                if(pe.getValue()==CAO_Constants.ONE_TO_ONE_PROCESSOR){ isOneToOneModel = true;}
            }
        }
        
        return isOneToOneModel;
    }
    */
    global static boolean isOneToOne() {        
        //if no settings exist, create defaults
        if (CAO_Constants.getContactsSettings().npe01__Account_Processor__c==ONE_TO_ONE_PROCESSOR) {
            return true;
        } else {
            return false;
        }        
    }
    
    global static boolean isBucketModel() {
        return (CAO_Constants.getContactsSettings().npe01__Account_Processor__c == BUCKET_PROCESSOR);
    }
    
    global static boolean isHHAccountModel() {
        return (CAO_Constants.getContactsSettings().npe01__Account_Processor__c == HH_ACCOUNT_PROCESSOR);
    }
    
    /// <name> triggerAction </name>
    /// <summary> contains possible actions for a trigger </summary>
    public enum triggerAction {beforeInsert, beforeUpdate, beforeDelete, afterInsert, afterUpdate, afterDelete, afterUndelete}
    
    public static Id IndividualAccountId; 
    
    //variable for Account Name
    private static String IndividualAccountName = CAO_Constants.BUCKET_ACCOUNT_NAME;

    global static id GetIndividualAccountId () {
    
        // look up the ID if we haven't already done it
        if ( IndividualAccountId == null ) {
            List<Account> acct = [select id,npe01__SYSTEMISINDIVIDUAL__c,npe01__SYSTEM_AccountType__c from account where Name =:IndividualAccountName LIMIT 1];
            if(acct.size()>0){
                
                if(acct[0].npe01__SYSTEMISINDIVIDUAL__c==false || acct[0].npe01__SYSTEM_AccountType__c<>CAO_Constants.BUCKET_ORGANIZATION_TYPE){
                    acct[0].npe01__SYSTEMISINDIVIDUAL__c = true;
                    acct[0].npe01__SYSTEM_AccountType__c = CAO_Constants.BUCKET_ORGANIZATION_TYPE;
                    update acct[0];
                }
                IndividualAccountId = acct[0].id;   
            }           
        }
        return IndividualAccountId;
    }
    
    global static Id setIndividualAccountForTests(String accountName) {
        //create a fake Individual Account for tests

        Account individualAccountForTests = new Account(
            Name=accountName,
            npe01__SYSTEMISINDIVIDUAL__c = true,
            npe01__SYSTEM_AccountType__c = CAO_Constants.BUCKET_ORGANIZATION_TYPE
        );
        
        insert individualAccountForTests;
        
        CAO_Constants.BUCKET_ACCOUNT_NAME = accountName;
        IndividualAccountName = accountName;
        
        return individualAccountForTests.id;
        
    }

}