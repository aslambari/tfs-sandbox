<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PR_Closed</fullName>
        <description>PR Closed</description>
        <protected>false</protected>
        <recipients>
            <field>Developer__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/PR_Closed</template>
    </alerts>
    <alerts>
        <fullName>PR_ReadyForReview_Email</fullName>
        <description>PR ReadyForReview Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>alan@theforcesolution.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/PR_Complete</template>
    </alerts>
    <alerts>
        <fullName>Re_open_PR</fullName>
        <description>Re-open PR</description>
        <protected>false</protected>
        <recipients>
            <field>Developer__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/PR_Re_opened</template>
    </alerts>
    <alerts>
        <fullName>Send_PR_Info_to_Developer</fullName>
        <description>Send PR Info to Developer</description>
        <protected>false</protected>
        <recipients>
            <field>Developer__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/PR_Ready_For_Work</template>
    </alerts>
    <rules>
        <fullName>PR Closed</fullName>
        <actions>
            <name>PR_Closed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Re-open PR</fullName>
        <actions>
            <name>Re_open_PR</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Re-Opened</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send PR Info to Developer</fullName>
        <actions>
            <name>Send_PR_Info_to_Developer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(Status__c, &apos;Requested&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send PR Ready For Review Email</fullName>
        <actions>
            <name>PR_ReadyForReview_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Project_Request__c.Status__c</field>
            <operation>equals</operation>
            <value>Ready For Review</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
