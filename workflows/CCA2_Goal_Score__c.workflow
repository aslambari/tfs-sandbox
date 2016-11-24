<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>SetUniqueIdOnGoalScore</fullName>
        <field>Unique_Id__c</field>
        <formula>Answer__c + &apos;_&apos; + CCA2_Goals__c</formula>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>SetUniqueIdOnGoalScore</fullName>
        <actions>
            <name>SetUniqueIdOnGoalScore</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
