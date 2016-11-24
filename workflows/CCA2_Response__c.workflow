<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SetUniqueIdOnRe</fullName>
        <field>Unique_Id__c</field>
        <formula>CCA2_Application__c + &apos;_&apos; + CCA2_Question__c</formula>
        <name>SetUniqueIdOnRe</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>SetUniqueIdOnResponse</fullName>
        <actions>
            <name>SetUniqueIdOnRe</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
