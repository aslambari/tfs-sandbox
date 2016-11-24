<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <tasks>
        <fullName>Here%27s a task after the approval proc</fullName>
        <assignedTo>alan@theforcesolution.com.tfs</assignedTo>
        <assignedToType>user</assignedToType>
        <description>This should NOT be assgned till the approval step is complete</description>
        <dueDateOffset>5</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <offsetFromField>Case.CreatedDate</offsetFromField>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
    </tasks>
</Workflow>
