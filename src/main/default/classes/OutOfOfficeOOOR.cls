/*
Author: Demen Selcan
E-Mail: dselcan@salesforce.com
Last Updated: 27th Jun 2021
*/

public with sharing class OutOfOfficeOOOR {
  // sanitizing method to check if field and object are valid and accessible
  public boolean isSafeFieldAndObject(String objName, String fieldName) {
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    SObjectType myObj = schemaMap.get(objName);
    if (myObj.getDescribe().isAccessible()) {
      SObjectField myField = myObj.getDescribe().fields.getMap().get(fieldName);
      if (myField.getDescribe().isAccessible()) {
        return true;
      }
    }
    System.debug(
      'Please check your field entry in OutOfTheOfficeSettings_OOOR__mdt. Here is what you have entered: ' +
      myObj.getDescribe().fields.getMap().get(fieldName) +
      ' There might be a typo, or your user may not have FLS permission for that.'
    );
    return false;
  }

  // sanitizing method to check if record type is valid and accessible
  public boolean isSafeRecordType(String objName, String recordTypeAPIName) {
    Boolean isRecordTypeAvailable = false;
    Map<String, Schema.RecordTypeInfo> recordTypeMap = Schema.getGlobalDescribe()
      .get(objName)
      .getDescribe()
      .getRecordTypeInfosByDeveloperName();
    if (recordTypeMap.get(recordTypeAPIName).isActive()) {
      return true;
    }
    System.debug(
      'Please check your record type for objecttype: ' +
      objName +
      ' and record type entry ' +
      recordTypeAPIName +
      ' Is Record Type Active? ' +
      recordTypeMap.get(recordTypeAPIName).isActive() +
      '. There might be a typo or it is inactive.'
    );
    return false;
  }

  // method to build the where clause for dynamic soql. It checks if the field is a string or not.
  // If string it uses the escapeSingleQuotes method. If not String, the valueOf method is applied.
  public string buildWhereClause(
    String whereString,
    String objectName,
    String fieldName,
    String queryParameter,
    String soqlQuery,
    String recordType
  ) {
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    SObjectType myObj = schemaMap.get(objectName);
    SObjectField myField = myObj.getDescribe().fields.getMap().get(fieldName);
    String myFieldType = String.valueOf(myField.getDescribe().getSoapType());
    if (myFieldType != 'String' && recordType != null) {
      return whereString +
        fieldName +
        queryParameter +
        String.valueof(soqlQuery) +
        ' AND RecordType.DeveloperName = ' +
        '\'' +
        String.escapeSingleQuotes(recordType) +
        '\' ';
    }
    if (myFieldType != 'String' && recordType == null) {
      return whereString +
        fieldName +
        queryParameter +
        String.valueof(soqlQuery);
    }
    if (myFieldType == 'String' && recordType != null) {
      return whereString +
        fieldName +
        queryParameter +
        '\'' +
        String.escapeSingleQuotes(soqlQuery) +
        '\' ' +
        ' AND RecordType.DeveloperName = ' +
        '\'' +
        String.escapeSingleQuotes(recordType) +
        '\' ';
    }
    if (myFieldType == 'String' && recordType == null) {
      return whereString +
        fieldName +
        queryParameter +
        '\'' +
        String.escapeSingleQuotes(soqlQuery) +
        '\' ';
    } else {
      return null;
    }
  }
  List<SObject> recordsToBeReassigned = new List<SObject>();
  public List<SObject> getRecordsToBeReassigned(List<SObject> queryResult) {
    /*
    Looping through the OOO Records. If the OOO Requestor equals the records to be re-assigned,
     the loop updates each record with the backup owner Id from the original OOO record.
     */
    for (OutOfOfficeRequest_OOOR__c oooRecord : [
      SELECT Id, BackupUser_OOOR__c, PersonTakingTimeOff_OOOR__c, Status_OOOR__c
      FROM OutOfOfficeRequest_OOOR__c
      WHERE
        StartDate_OOOR__c <= TODAY
        AND EndDate_OOOR__c >= TODAY
        AND Status_OOOR__c = 'Approved'
    ]) {
      for (Sobject objectToBeInserted : queryResult) {
        // This if statement is needed to make sure that multiple OOO records aren't conflicing with each other.
        if (
          objectToBeInserted.get('OwnerId') ==
          oooRecord.PersonTakingTimeOff_OOOR__c
        ) {
          objectToBeInserted.put('OwnerId', oooRecord.BackupUser_OOOR__c);
          recordsToBeReassigned.add(objectToBeInserted);
        }
      }
    }
    return recordsToBeReassigned;
  }

  List<SObject> feeditemsToBeUpdated = new List<SObject>();

  public List<SObject> getFeedPosts(
    List<SObject> recordsToBeUpdated,
    List<OutOfTheOfficeSettings_OOOR__mdt> metadataQuerySettings
  ) {
    for (SObject recordToBeUpdated : recordsToBeUpdated) {
      for (
        OutOfTheOfficeSettings_OOOR__mdt metadataQuerySetting : metadataQuerySettings
      ) {
        if (
          // Need this if statement to make sure that every record gets updated by only the corresponding MDT record
          metadataQuerySetting.FeedPost_OOOR__c == true &&
          recordToBeUpdated.getSObjectType().getDescribe().getName() ==
          metadataQuerySetting.ObjectAPIName_OOOR__c &&
          recordToBeUpdated.getSObjectType().getDescribe().isFeedEnabled()
        ) {
          FeedItem fi = new FeedItem(
            ParentId = recordToBeUpdated.Id,
            Body = metadataQuerySetting.FeedPostMessage_OOOR__c,
            Type = 'TextPost'
          );
          feeditemsToBeUpdated.add(fi);
        }
      }
    }
    return feeditemsToBeUpdated;
  }
}
