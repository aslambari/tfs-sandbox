<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>PR Closed</fullName>
        <protected>false</protected>
        <recipients>
            <field>Developer__c</field>
            <type>contactLookup</type>
        </recipients>
        <template>unfiled$public/PR_Closed</template>
    </alerts>
    <alerts>
        <fullName>PR ReadyForReview Email</fullName>
        <protected>false</protected>
        <recipients>
            <recipient>alan@theforcesolution.com.tfs</recipient>
            <type>user</type>
        </recipients>
        <template>unfiled$public/PR_Complete</template>
    </alerts>
    <alerts>
        <fullName>Re-open PR</fullName>
        <protected>false</protected>
        <recipients>
            <field>Developer__c</field>
            <type>contactLookup</type>
        </recipients>
        <template>unfiled$public/PR_Re_opened</template>
    </alerts>
    <alerts>
        <fullName>Send PR Info to Developer</fullName>
        <protected>false</protected>
        <recipients>
            <field>Developer__c</field>
            <type>contactLookup</type>
        </recipients>
        <template>unfiled$public/PR_Ready_For_Work</template>
    </alerts>
    <rules>
        <fullName>PR Closed</fullName>
        <actions>
            <name>PR Closed</name>
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
            <name>Re-open PR</name>
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
            <name>Send PR Info to Developer</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISPICKVAL(Status__c, &apos;Requested&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Send PR Ready For Review Email</fullName>
        <actions>
            <name>PR ReadyForReview Email</name>
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
