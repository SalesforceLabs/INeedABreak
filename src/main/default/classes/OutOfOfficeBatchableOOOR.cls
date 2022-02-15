/*
Author: Demen Selcan
E-Mail: dselcan@salesforce.com
Last Updated: 27th Jun 2021
*/

public with sharing class OutOfOfficeBatchableOOOR implements Database.Batchable<SObject>, Database.Stateful {
  private Integer settingsIndex = 0;
  // Doesn't count against governors as we are querying CMDT. This helps to reference this list across all methods.
  @testVisible
  public static List<OutOfTheOfficeSettings_OOOR__mdt> querySettings {
    get {
      if (querySettings == null) {
        querySettings = [
          SELECT
            ObjectAPIName_OOOR__c,
            Active_OOOR__c,
            FeedPost_OOOR__c,
            FeedPostMessage_OOOR__c,
            FieldName_OOOR__c,
            QueryParameter_OOOR__c,
            QueryFilter_OOOR__c,
            RecordType_OOOR__c
          FROM OutOfTheOfficeSettings_OOOR__mdt
          WHERE Active_OOOR__c = TRUE
        ];
      }
      return querySettings;
    }
    set;
  }

  public List<SObject> start(Database.BatchableContext BC) {
    OutOfOfficeOOOR outOfOfficeClass = new OutOfOfficeOOOR();
    //Get out of office records from OutOfOfficeRequest_OOOR__c and return results. This contains all users that are OOO and the corresponding dates
    Set<Id> userIdsCurrentlyOOO = new Set<Id>();
    for (OutOfOfficeRequest_OOOR__c oooRecord : [
      SELECT Id, BackupUser_OOOR__c, PersonTakingTimeOff_OOOR__c, Status_OOOR__c
      FROM OutOfOfficeRequest_OOOR__c
      WHERE
        StartDate_OOOR__c <= TODAY
        AND EndDate_OOOR__c >= TODAY
        AND Status_OOOR__c = 'Approved'
    ]) {
      userIdsCurrentlyOOO.add(oooRecord.PersonTakingTimeOff_OOOR__c);
    }

    // Call outOfOfficeClass.buildWhereClause method which checks the field types to query and applies SOQL Injection safety methods.
    String selectStatement =
      'SELECT Id, OwnerId FROM ' +
      querySettings[settingsIndex].ObjectAPIName_OOOR__c;

    String whereClause = outOfOfficeClass.buildWhereClause(
      ' WHERE ',
      querySettings[settingsIndex].ObjectAPIName_OOOR__c,
      querySettings[settingsIndex].FieldName_OOOR__c,
      querySettings[settingsIndex].QueryParameter_OOOR__c,
      querySettings[settingsIndex].QueryFilter_OOOR__c,
      querySettings[settingsIndex].RecordType_OOOR__c
    );

    // Build the where clause which is being passed to execution method eventually.
    String scope =
      selectStatement +
      whereClause +
      ' AND OwnerId IN : ' +
      'userIdsCurrentlyOOO';

    // calling a sanitizing function which checks if the object and field name are valid and validates CRUD, too.
    if (
      !(outOfOfficeClass.isSafeFieldAndObject(
        querySettings[settingsIndex].ObjectAPIName_OOOR__c,
        querySettings[settingsIndex].FieldName_OOOR__c
      ))
    ) {
      return null;
    } else if (
      // calling a sanitizing function which checks if the record type name is valid.
      querySettings[settingsIndex].RecordType_OOOR__c != null &&
      !(outOfOfficeClass.isSafeRecordType(
        querySettings[settingsIndex].ObjectAPIName_OOOR__c,
        querySettings[settingsIndex].RecordType_OOOR__c
      ))
    ) {
      return null;
    } else {
      System.debug('What is the query returned by start method? ' + scope);
      return Database.query(scope);
    }
  }

  public void execute(Database.BatchableContext BC, List<SObject> scope) {
    OutOfOfficeOOOR outOfOfficeClass = new OutOfOfficeOOOR();
    List<SObject> recordsToBeUpdated = outOfOfficeClass.getRecordsToBeReassigned(
      scope
    );

    List<SObject> recordFeedPosts = outOfOfficeClass.getFeedPosts(
      scope,
      querySettings
    );

    // update records with backup user and insert Feedpost if enabled
    if (recordsToBeUpdated.size() > 0) {
      update recordsToBeUpdated;
      if (recordFeedPosts.size() > 0) {
        insert recordFeedPosts;
      }
    }
  }

  public void finish(Database.BatchableContext BC) {
    if (settingsIndex < querySettings.size() - 1) {
      settingsIndex++;
      Database.executeBatch(this);
    }
  }
}
