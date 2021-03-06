/*
    Copyright (c) 2011, Salesforce.com Foundation
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
* @description This class contains unit tests for validating the behavior of the Household Opportunity Contact Role class
*/
@isTest
private class HH_OppContactRoles_TEST {
    
    static testMethod void HouseholdOpportunity() {
        HH_OppContactRoles_TDTM testHouseholdOpportunity = new HH_OppContactRoles_TDTM(); 
    }
    //test for individual account model
    
    static testMethod void opportunityWithHousehold() {
        
        npe01__Contacts_and_Orgs_Settings__c contactSettingsForTests = CAO_Constants.getContactsSettingsForTests(new npe01__Contacts_and_Orgs_Settings__c (npe01__Account_Processor__c = CAO_Constants.ONE_TO_ONE_PROCESSOR,npe01__Opportunity_Contact_Role_Default_role__c = 'Donor'));
        
        npo02__Households_Settings__c householdSettingsForTests = HH_Households.getHouseholdsSettingsForTests(new npo02__Households_Settings__c (npo02__Household_Rules__c = HH_Households.ALL_PROCESSOR, npo02__Household_Contact_Roles_On__c = true,npo02__Household_Member_Contact_Role__c='Household Credit'));
                
        //create contact

        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            npe01__WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS, 
            npe01__Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            npe01__WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            npe01__PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        Contact[] createdContacts = [select AccountId,npo02__Household__c from Contact where id=:con.id];
        Id accountId = createdContacts[0].AccountId;
        Id householdId = createdContacts[0].npo02__household__c;
        //create household member
        Contact con2 = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            npe01__WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS, 
            npe01__Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            npe01__WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            npe01__PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS,
            npo02__Household__c = householdId
        );
        insert con2;
        //create opportunity
        Opportunity o = new Opportunity(
            Name='test oppty',
            CloseDate=date.newInstance(2001,12,12),
            StageName=UTIL_UnitTestData_TEST.getClosedWonStage(),
            Amount=100,
            AccountId=accountId
        );
        insert o;
        //check for contact roles
        List<OpportunityContactRole> createdRoles = [select Role, ContactId, IsPrimary from OpportunityContactRole where OpportunityId = :o.id order by ContactId];
        system.AssertEquals(2,createdRoles.size());
        system.AssertEquals('Donor',createdRoles[0].Role);
        system.Assert(createdRoles[0].IsPrimary);
        system.AssertEquals('Household Credit',createdRoles[1].Role);
    }
    /*
    static testMethod void opportunityWithHouseholdBucket() {
        
        String householdContactRolesOn = system.label.Household_Contact_Role_Processor_On;  
        //create contact
        String newContactfirstName = 'test';
        String newContactLastName = 'Contact_forTests';
        Contact con = new Contact(
            FirstName=newContactfirstName,
            LastName=newContactLastName,
            SystemHouseholdProcessor__c = 'All New or Edited Contacts',
            npe01__SystemAccountProcessor__c = 'Individual'
        );
        insert con;
        Contact[] createdContacts = [select AccountId,npo02__Household__c from Contact where id=:con.id];
        Id accountId = createdContacts[0].AccountId;
        Id householdId = createdContacts[0].npo02__household__c;
        //create household member
        Contact con2 = new Contact(
            FirstName=newContactfirstName,
            LastName=newContactLastName,
            SystemHouseholdProcessor__c = 'All New or Edited Contacts',
            npo02__Household__c = householdId
        );
        insert con2;
        //create opportunity
        Opportunity o = new Opportunity(
            Name='test oppty',
            CloseDate=date.newInstance(2001,12,12),
            StageName=UTIL_UnitTestData_TEST.getClosedWonStage(),
            Amount=100,
            AccountId=accountId,
            systemHouseholdContactRoleProcessor__c = householdContactRolesOn
        );
        insert o;
        
        //check for contact roles
        List<OpportunityContactRole> createdRoles = [select Role, ContactId, IsPrimary from OpportunityContactRole where OpportunityId = :o.id order by ContactId];
        system.AssertEquals(2,createdRoles.size());
        system.AssertEquals('Donor',createdRoles[0].Role);
        system.Assert(createdRoles[0].IsPrimary);
        system.AssertEquals('Household Credit',createdRoles[1].Role);
    }
    */
    static testMethod void opportunityWithHouseholdNoRoles() {
        
        npe01__Contacts_and_Orgs_Settings__c contactSettingsForTests = CAO_Constants.getContactsSettingsForTests(new npe01__Contacts_and_Orgs_Settings__c (npe01__Account_Processor__c = CAO_Constants.ONE_TO_ONE_PROCESSOR));
        
        npo02__Households_Settings__c householdSettingsForTests = HH_Households.getHouseholdsSettingsForTests(new npo02__Households_Settings__c (npo02__Household_Rules__c = HH_Households.ALL_PROCESSOR, npo02__Household_Contact_Roles_On__c = false));

        // put in the handler as inactive, to mimic turning the custom setting off.
        List<Trigger_Handler__c> handlers = new List<Trigger_Handler__c>();
        handlers.add(new Trigger_Handler__c(Active__c = false, Asynchronous__c = false, 
              Class__c = 'HH_OppContactRoles_TDTM', Load_Order__c = 1, Object__c = 'Opportunity', 
              Trigger_Action__c = 'AfterInsert'));
        insert handlers;
        
        //create contact
        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            npe01__WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS, 
            npe01__Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            npe01__WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            npe01__PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        Contact[] createdContacts = [select AccountId,npo02__Household__c from Contact where id=:con.id];
        Id accountId = createdContacts[0].AccountId;
        Id householdId = createdContacts[0].npo02__household__c;
        //create household member
        Contact con2 = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            npe01__WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS, 
            npe01__Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            npe01__WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            npe01__PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS,
            npo02__Household__c = householdId
        );
        insert con2;
        //create opportunity
        Opportunity o = new Opportunity(
            Name='test oppty',
            CloseDate=date.newInstance(2001,12,12),
            StageName=UTIL_UnitTestData_TEST.getClosedWonStage(),
            Amount=100,
            AccountId=accountId
        );
        insert o;
        //check for contact roles
        List<OpportunityContactRole> createdRoles = [select Role, ContactId, IsPrimary from OpportunityContactRole where OpportunityId = :o.id order by ContactId];
        system.AssertEquals(0,createdRoles.size());
    }
    static testMethod void opportunityWithNoHousehold() {
        
        npe01__Contacts_and_Orgs_Settings__c contactSettingsForTests = CAO_Constants.getContactsSettingsForTests(
            new npe01__Contacts_and_Orgs_Settings__c (npe01__Account_Processor__c = CAO_Constants.ONE_TO_ONE_PROCESSOR));
                
        npo02__Households_Settings__c householdSettingsForTests = HH_Households.getHouseholdsSettingsForTests(
            new npo02__Households_Settings__c (npo02__Household_Rules__c = HH_Households.NO_HOUSEHOLDS_PROCESSOR, 
                npo02__Household_Contact_Roles_On__c = true));
        
        //create contact

        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            npe01__WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS, 
            npe01__Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            npe01__WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            npe01__PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con;
        
        //Disabling trigger
        Trigger_Handler__c triggerHandler = [select Active__c from Trigger_Handler__c where Class__c = 'OPP_OpportunityContactRoles_TDTM'];
		triggerHandler.Active__c = false;
		update triggerHandler;
        
        Contact[] createdContacts = [select AccountId,npo02__Household__c from Contact where id=:con.id];
        Id accountId = createdContacts[0].AccountId;
        Id householdId = createdContacts[0].npo02__household__c;
        //create household member
        Contact con2 = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            npe01__WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS, 
            npe01__Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            npe01__WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            npe01__PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS
        );
        insert con2;
        //create opportunity
        Opportunity o = new Opportunity(
            Name='test oppty',
            CloseDate=date.newInstance(2001,12,12),
            StageName=UTIL_UnitTestData_TEST.getClosedWonStage(),
            Amount=100,
            AccountId=accountId
        );
        insert o;
        //check for contact roles
        List<OpportunityContactRole> createdRoles = [select Role, ContactId, IsPrimary from OpportunityContactRole where OpportunityId = :o.id order by ContactId];
        system.AssertEquals(0,createdRoles.size());
    }
    static testMethod void opportunityRegularAccount() {
        
        npo02__Households_Settings__c householdSettingsForTests = HH_Households.getHouseholdsSettingsForTests(new npo02__Households_Settings__c (npo02__Household_Rules__c = HH_Households.ALL_PROCESSOR, npo02__Household_Contact_Roles_On__c = true));
        
        //create contact
        Account acct = new Account(
            Name = 'fake account'
        );
        insert acct;
        Id accountId = acct.Id;

        Contact con = new Contact(
            FirstName=CAO_Constants.CONTACT_FIRSTNAME_FOR_TESTS,
            LastName=CAO_Constants.CONTACT_LASTNAME_FOR_TESTS,
            npe01__WorkEmail__c = CAO_Constants.CONTACT_EMAIL_FOR_TESTS, 
            npe01__Preferred_Email__c = CAO_Constants.CONTACT_PREFERRED_EMAIL_FOR_TESTS,
            npe01__WorkPhone__c = CAO_Constants.CONTACT_PHONE_FOR_TESTS,
            npe01__PreferredPhone__c = CAO_Constants.CONTACT_PREFERRED_PHONE_FOR_TESTS,
            accountId = accountId
        );
        insert con;
        Contact[] createdContacts = [select AccountId,npo02__Household__c from Contact where id=:con.id];
        
        Id householdId = createdContacts[0].npo02__household__c;
        
        //create opportunity
        Opportunity o = new Opportunity(
            Name='test oppty',
            CloseDate=date.newInstance(2001,12,12),
            StageName=UTIL_UnitTestData_TEST.getClosedWonStage(),
            Amount=100,
            AccountId=accountId
        );
        insert o;
        //check for contact roles
        List<OpportunityContactRole> createdRoles = [select Role, ContactId, IsPrimary from OpportunityContactRole where OpportunityId = :o.id order by ContactId];
        system.AssertEquals(0,createdRoles.size());
    }
    
    static testmethod void ghIssue25() {
        npe01__Contacts_and_Orgs_Settings__c contactSettingsForTests = CAO_Constants.getContactsSettingsForTests(new npe01__Contacts_and_Orgs_Settings__c (npe01__Enable_Opportunity_Contact_Role_Trigger__c = true,npe01__Opportunity_Contact_Role_Default_role__c = 'Donor',npe01__Account_Processor__c = 'One-to-One'));
        npo02__Households_Settings__c householdSettingsForTests = HH_Households.getHouseholdsSettingsForTests(new npo02__Households_Settings__c ( npo02__Household_Contact_Roles_On__c = true,npo02__Household_Member_Contact_Role__c = 'Household Member'));
       
        npo02__Household__c hh = new npo02__Household__c(Name ='hh');
        insert hh;
        Contact con1= new Contact(LastName='test1',npo02__Household__c = hh.id);
        Contact con2= new Contact(LastName='test2');
        insert con1;
        insert con2;

        Opportunity o1 = new Opportunity(
            Name = 'o1',
            StageName = UTIL_UnitTestData_TEST.getClosedWonStage(),
            CloseDate = System.today(),
            npe01__Contact_Id_for_Role__c = (string)con1.id);
        insert o1;
        Opportunity o2 = new Opportunity(
            Name = 'o2',
            StageName = UTIL_UnitTestData_TEST.getClosedWonStage(),
            CloseDate = System.today(),
            npe01__Contact_Id_for_Role__c = (string)con2.id);
        insert o2;        

        system.assertequals(2,(integer)[select count() from Opportunity]);
        system.assertequals(2,(integer)[select count() from OpportunityContactRole]);
    }  
    
       
}