<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SetUniqueIdOnAccountGoal</fullName>
        <field>Unique_Id__c</field>
        <formula>Account__c + &apos;_&apos; + CCA2_Goal__c</formula>
        <name>SetUniqueIdOnAccountGoal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>SetUniqueIdOnAccountGoal</fullName>
        <actions>
            <name>SetUniqueIdOnAccountGoal</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
