<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Unique_Id</fullName>
        <field>Unique_Id__c</field>
        <formula>CCA2_Goal__c + &apos;_&apos; +  CCA2_Question__c</formula>
        <name>Set Unique Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Enforce Uniqueness</fullName>
        <actions>
            <name>Set_Unique_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
