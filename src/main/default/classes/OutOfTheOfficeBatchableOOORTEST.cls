/*
Author: Demen Selcan
E-Mail: dselcan@salesforce.com
Last Updated: 28th Jun 2021
*/

@isTest
private class OutOfTheOfficeBatchableOOORTEST {
  @isTest
  // 1 user out of office
  // CMDT Query: Case Object, Field Type Boolean, No Record Type
  // Dynamic Query will be escaped
  // Will Result in Following Query passed to OutOfOfficeBatchableOOOR.cls and OutOfOffice.cls: SELECT Id, OwnerId FROM Case WHERE IsClosed = false AND OwnerID IN: userIdsCurrentlyOOO
  // this method is testing a query with a string in the where clause and no record type for the case object, created dynamically by custom metadata.
  // 45 Cases should get re-assigned to the backup user
  static void createTestDataWithCaseBooleanNoRecordType() {
    List<Case> caseRecords = createCases();
    insert caseRecords;

    User backupUser = createBackUpUser();
    insert backupUser;

    User timeOffUser = createTimeOffUser();
    insert timeOffUser;

    OutOfOfficeRequest_OOOR__c outOfOfficeRecord = createTimeOffRecord(
      timeOffUser.Id,
      backupUser.Id
    );
    insert outOfOfficeRecord;

    List<OutOfTheOfficeSettings_OOOR__mdt> cmdtCaseBooleanNoRecordType = createCMDTCaseBooleanNoRecordType();

    List<Case> reAssignCasesToTimeOffUser = reAssignCasesToTimeOffUser(
      timeOffUser.Id,
      45
    );
    update reAssignCasesToTimeOffUser;

    List<Case> timeoffUserCases = [
      SELECT Id, OwnerId, Owner.Name
      FROM Case
      WHERE Owner.Name = 'timeOff'
    ];

    List<Case> backupUserCases = [
      SELECT Id, OwnerId, Owner.Name
      FROM Case
      WHERE Owner.Name = 'backup'
    ];

    // 200 cases have been created and 45 of them are owned by the user who is out of office. Prior to the batch run
    System.assertEquals(
      45,
      timeoffUserCases.size(),
      'We expect 45 cases where time off user is the owner'
    );

    // the backup user doesn't have any cases assigned to him prior to the batch run
    System.assertEquals(
      0,
      backupUserCases.size(),
      'We expect 0 cases for the backup user prior to the batch job'
    );

    Test.startTest();
    OutOfOfficeBatchableOOOR.querySettings = cmdtCaseBooleanNoRecordType;
    Database.executeBatch(new OutOfOfficeBatchableOOOR());
    Test.stopTest();

    List<Case> timeoffUserCasesAfterBatch = [
      SELECT Id, OwnerId, Owner.Name
      FROM Case
      WHERE Owner.Name = 'timeOff'
    ];

    List<Case> backupUserCasesAfterBatch = [
      SELECT Id, OwnerId, Owner.Name
      FROM Case
      WHERE Owner.Name = 'backup'
    ];

    // after the batch run, the user who is out of the office shouldn't own any cases himself any longer
    System.assertEquals(
      0,
      timeoffUserCasesAfterBatch.size(),
      'We expect 0 cases for the timeoff user now'
    );

    // after the batch run, the backup user should have received the 45 cases
    System.assertEquals(
      45,
      backupUserCasesAfterBatch.size(),
      'We expect 45 cases that have been re-assigned to the backup user now'
    );
  }

  @isTest
  // 1 user out of office
  // CMDT Query: Task Object, Field Type String, No Record Type
  // Dynamic Query will be escaped
  // Will Result in Following Query passed to OutOfOfficeBatchableOOOR.cls and OutOfOffice.cls: SELECT Id, OwnerId FROM Task WHERE Status != 'Completed' AND OwnerID IN: userIdsCurrentlyOOO
  // this method is testing a query with a string and no record type in the where clause for the task object, created dynamically by custom metadata.
  // 90 Tasks should get re-assigned to the backup user
  static void createTestDataWithTaskStringNoRecordType() {
    List<Task> taskRecords = createTasks();
    insert taskRecords;

    User backupUser = createBackUpUser();
    insert backupUser;

    User timeOffUser = createTimeOffUser();
    insert timeOffUser;

    OutOfOfficeRequest_OOOR__c outOfOfficeRecord = createTimeOffRecord(
      timeOffUser.Id,
      backupUser.Id
    );
    insert outOfOfficeRecord;

    List<OutOfTheOfficeSettings_OOOR__mdt> cmdtTaskStringNoRecordType = createCMDTTaskStringNoRecordType();

    List<Task> reAssignTasksToTimeOffUser = reAssignTasksToTimeOffUser(
      timeOffUser.Id,
      90
    );
    update reAssignTasksToTimeOffUser;

    List<Task> timeoffUserTasks = [
      SELECT Id, OwnerId, Owner.Name
      FROM Task
      WHERE Owner.Name = 'timeOff'
    ];

    List<Task> backupUserTasks = [
      SELECT Id, OwnerId, Owner.Name
      FROM Task
      WHERE Owner.Name = 'backup'
    ];

    // 200 tasks have been created and 45 of them are owned by the user who is out of office. Prior to the batch run
    System.assertEquals(
      90,
      timeoffUserTasks.size(),
      'We expect 90 tasks where time off user is the owner'
    );

    // the backup user doesn't have any cases assigned to him prior to the batch run
    System.assertEquals(
      0,
      backupUserTasks.size(),
      'We expect 0 tasks for the backup user prior to the batch job'
    );

    Test.startTest();
    OutOfOfficeBatchableOOOR.querySettings = cmdtTaskStringNoRecordType;
    Database.executeBatch(new OutOfOfficeBatchableOOOR());
    Test.stopTest();

    List<Task> timeoffUserTasksAfterBatch = [
      SELECT Id, OwnerId, Owner.Name
      FROM Task
      WHERE Owner.Name = 'timeOff'
    ];

    List<Task> backupUserTasksAfterBatch = [
      SELECT Id, OwnerId, Owner.Name
      FROM Task
      WHERE Owner.Name = 'backup'
    ];

    // after the batch run, the user who is out of the office shouldn't own any cases himself any longer
    System.assertEquals(
      0,
      timeoffUserTasksAfterBatch.size(),
      'We expect 0 tasks for the timeoff user now'
    );

    // after the batch run, the backup user should have received the 45 cases
    System.assertEquals(
      90,
      backupUserTasksAfterBatch.size(),
      'We expect 90 tasks that have been re-assigned to the backup user now'
    );
  }

  @isTest
  // 1 user out of office
  // CMDT Query: Task Object, Field Type String, With Record Type
  // Dynamic Query will be escaped
  // Will Result in Following Query passed to OutOfOfficeBatchableOOOR.cls and OutOfOffice.cls: SELECT Id, OwnerId FROM Task WHERE Status != 'Completed' AND RecordType.DeveloperName = 'TESTRECORDTYPE_OOOR' AND OwnerID IN: userIdsCurrentlyOOO
  // this method is testing a query with a string and no record type in the where clause for the task object, created dynamically by custom metadata.
  // 90 Tasks should get re-assigned to the backup user
  static void createTestDataWithTaskStringWithRecordType() {
    List<Task> taskRecords = createTasks();
    insert taskRecords;

    User backupUser = createBackUpUser();
    insert backupUser;

    User timeOffUser = createTimeOffUser();
    insert timeOffUser;

    OutOfOfficeRequest_OOOR__c outOfOfficeRecord = createTimeOffRecord(
      timeOffUser.Id,
      backupUser.Id
    );
    insert outOfOfficeRecord;

    List<OutOfTheOfficeSettings_OOOR__mdt> cmdtTaskStringWithRecordType = createCMDTTaskStringWithRecordType();

    List<Task> reAssignTasksToTimeOffUser = reAssignTasksToTimeOffUser(
      timeOffUser.Id,
      90
    );
    update reAssignTasksToTimeOffUser;

    List<Task> timeoffUserTasks = [
      SELECT Id, OwnerId, Owner.Name
      FROM Task
      WHERE Owner.Name = 'timeOff'
    ];

    List<Task> backupUserTasks = [
      SELECT Id, OwnerId, Owner.Name
      FROM Task
      WHERE Owner.Name = 'backup'
    ];

    // 200 tasks have been created and 45 of them are owned by the user who is out of office. Prior to the batch run
    System.assertEquals(
      90,
      timeoffUserTasks.size(),
      'We expect 90 tasks where time off user is the owner'
    );

    // the backup user doesn't have any cases assigned to him prior to the batch run
    System.assertEquals(
      0,
      backupUserTasks.size(),
      'We expect 0 tasks for the backup user prior to the batch job'
    );

    Test.startTest();
    OutOfOfficeBatchableOOOR.querySettings = cmdtTaskStringWithRecordType;
    Database.executeBatch(new OutOfOfficeBatchableOOOR());
    Test.stopTest();

    List<Task> timeoffUserTasksAfterBatch = [
      SELECT Id, OwnerId, Owner.Name
      FROM Task
      WHERE Owner.Name = 'timeOff'
    ];

    List<Task> backupUserTasksAfterBatch = [
      SELECT Id, OwnerId, Owner.Name
      FROM Task
      WHERE Owner.Name = 'backup'
    ];

    // after the batch run, the user who is out of the office shouldn't own any cases himself any longer
    System.assertEquals(
      0,
      timeoffUserTasksAfterBatch.size(),
      'We expect 0 tasks for the timeoff user now'
    );

    // after the batch run, the backup user should have received the 45 cases
    System.assertEquals(
      90,
      backupUserTasksAfterBatch.size(),
      'We expect 90 tasks that have been re-assigned to the backup user now'
    );
  }
  @isTest
  // 1 user out of office
  // CMDT Query: Task Object, Field Type Boolean, With Record Type
  // Dynamic Query will be escaped
  // Will Result in Following Query passed to OutOfOfficeBatchableOOOR.cls and OutOfOffice.cls: SELECT Id, OwnerId FROM Task WHERE IsReminderSet = false AND RecordTypeDeveloperName = 'TESTRECORDTYPE_OOOR' AND OwnerID IN: userIdsCurrentlyOOO
  // this method is testing a query with a boolean and record type in the where clause for the task object, created dynamically by custom metadata.
  // 90 Tasks should get re-assigned to the backup user
  static void createTestDataWithTaskBooleanWithRecordType() {
    List<Task> taskRecords = createTasks();
    insert taskRecords;

    User backupUser = createBackUpUser();
    insert backupUser;

    User timeOffUser = createTimeOffUser();
    insert timeOffUser;

    OutOfOfficeRequest_OOOR__c outOfOfficeRecord = createTimeOffRecord(
      timeOffUser.Id,
      backupUser.Id
    );
    insert outOfOfficeRecord;

    List<OutOfTheOfficeSettings_OOOR__mdt> cmdtTaskBooleanAndRecordType = createCMDTTaskBooleanWithRecordType();

    List<Task> reAssignTasksToTimeOffUser = reAssignTasksToTimeOffUser(
      timeOffUser.Id,
      90
    );
    update reAssignTasksToTimeOffUser;

    List<Task> timeoffUserTasks = [
      SELECT Id, OwnerId, Owner.Name
      FROM Task
      WHERE Owner.Name = 'timeOff'
    ];

    List<Task> backupUserTasks = [
      SELECT Id, OwnerId, Owner.Name
      FROM Task
      WHERE Owner.Name = 'backup'
    ];

    // 200 tasks have been created and 45 of them are owned by the user who is out of office. Prior to the batch run
    System.assertEquals(
      90,
      timeoffUserTasks.size(),
      'We expect 90 tasks where time off user is the owner'
    );

    // the backup user doesn't have any cases assigned to him prior to the batch run
    System.assertEquals(
      0,
      backupUserTasks.size(),
      'We expect 0 tasks for the backup user prior to the batch job'
    );

    Test.startTest();
    OutOfOfficeBatchableOOOR.querySettings = cmdtTaskBooleanAndRecordType;
    Database.executeBatch(new OutOfOfficeBatchableOOOR());
    Test.stopTest();

    List<Task> timeoffUserTasksAfterBatch = [
      SELECT Id, OwnerId, Owner.Name
      FROM Task
      WHERE Owner.Name = 'timeOff'
    ];

    List<Task> backupUserTasksAfterBatch = [
      SELECT Id, OwnerId, Owner.Name
      FROM Task
      WHERE Owner.Name = 'backup'
    ];

    // after the batch run, the user who is out of the office shouldn't own any cases himself any longer
    System.assertEquals(
      0,
      timeoffUserTasksAfterBatch.size(),
      'We expect 0 tasks for the timeoff user now'
    );

    // after the batch run, the backup user should have received the 45 cases
    System.assertEquals(
      90,
      backupUserTasksAfterBatch.size(),
      'We expect 90 tasks that have been re-assigned to the backup user now'
    );
  }

  public static List<Case> reAssignCasesToTimeOffUser(
    Id timeOffUser,
    Integer numberOfCases
  ) {
    List<Case> casesToBeReassigned = new List<Case>();
    List<Case> totalCases = [SELECT Id FROM Case LIMIT :numberOfCases];
    for (Case cs : totalCases) {
      cs.OwnerId = timeOffUser;
      casesToBeReassigned.add(cs);
    }
    return casesToBeReassigned;
  }

  public static List<Task> reAssignTasksToTimeOffUser(
    Id timeOffUser,
    Integer numberOfTasks
  ) {
    List<Task> tasksToBeReassigned = new List<Task>();
    List<Task> totalTasks = [SELECT Id FROM Task LIMIT :numberOfTasks];
    for (Task ts : totalTasks) {
      ts.OwnerId = timeOffUser;
      tasksToBeReassigned.add(ts);
    }
    return tasksToBeReassigned;
  }

  public static List<Case> createCases() {
    List<Case> testCases = TestDataFactoryOOOR.getCases(
      'Test Case',
      'Web',
      200
    );
    return testCases;
  }

  public static List<Task> createTasks() {
    List<Task> testTasks = TestDataFactoryOOOR.getTasks(
      'Test Task',
      'Not Started',
      'Normal',
      false,
      200
    );
    return testTasks;
  }

  public static User createTimeOffUser() {
    User testPersonTakingTimeOff = TestDataFactoryOOOR.generateUser(
      'System Administrator',
      'timeOff',
      'timeoff@example.com',
      'usertakingtimeoff@ooo.com.testuser',
      'oooh',
      'outOfOffice',
      'ooous'
    );
    return testPersonTakingTimeOff;
  }

  public static User createTimeOffUser2() {
    User testPersonTakingTimeOff2 = TestDataFactoryOOOR.generateUser(
      'System Administrator',
      'timeOff2',
      'timeoff2@example.com',
      'usertakingtimeoff2@ooo.com.testuser',
      'oooh2',
      'outOfOffice2',
      'ooou2'
    );
    return testPersonTakingTimeOff2;
  }

  public static User createBackUpUser() {
    User testBackUpUser = TestDataFactoryOOOR.generateUser(
      'System Administrator',
      'backup',
      'timeoff@example.com',
      'backupUser@ooo.com.testuser',
      'oooh',
      'backup',
      'backu'
    );
    return testBackUpUser;
  }

  public static User createBackUpUser2() {
    User testBackUpUser2 = TestDataFactoryOOOR.generateUser(
      'System Administrator',
      'backup2',
      'timeoff2@example.com',
      'backupUser2@ooo.com.testuser',
      'oooh',
      'backup2',
      'backu'
    );
    return testBackUpUser2;
  }

  public static OutOfOfficeRequest_OOOR__c createTimeOffRecord(
    Id testPersonTakingTimeOffId,
    Id testBackUpUserId
  ) {
    OutOfOfficeRequest_OOOR__c testOOORequest = TestDataFactoryOOOR.getOutOfOfficeRequestRecords(
      testPersonTakingTimeOffId,
      testBackUpUserId,
      'Approved',
      System.Today() - 1,
      System.Today() + 7
    );
    return testOOORequest;
  }

  public static List<OutOfTheOfficeSettings_OOOR__mdt> createCMDTCaseBooleanNoRecordType() {
    // active cmdt record for case object with active feedpost and record type
    List<OutOfTheOfficeSettings_OOOR__mdt> caseActiveWithRecordType = (List<OutOfTheOfficeSettings_OOOR__mdt>) Json.deserialize(
      '[{"ooor__ObjectAPIName_OOOR__c": "Case","ooor__Active_OOOR__c": true,"ooor__FeedPost_OOOR__c" : true, "ooor__FeedPostMessage_OOOR__c" : "This is the case feed", "ooor__FieldName_OOOR__c" : "IsClosed", "ooor__QueryParameter_OOOR__c" : "=", "ooor__QueryFilter_OOOR__c" : false}]',
      List<OutOfTheOfficeSettings_OOOR__mdt>.class
    );

    return caseActiveWithRecordType;
  }

  public static List<OutOfTheOfficeSettings_OOOR__mdt> createCMDTTaskStringWithRecordType() {
    // active cmdt record for task object with inactive feedpost and no record type
    List<OutOfTheOfficeSettings_OOOR__mdt> taskActiveStringWithRecordType = (List<OutOfTheOfficeSettings_OOOR__mdt>) Json.deserialize(
      '[{"ooor__ObjectAPIName_OOOR__c": "Task","ooor__Active_OOOR__c": true,"ooor__FeedPost_OOOR__c" : true, "ooor__FeedPostMessage_OOOR__c" : "This is the task feed", "ooor__FieldName_OOOR__c" : "Status", "ooor__QueryParameter_OOOR__c" : "!=", "ooor__QueryFilter_OOOR__c" : "Completed", "ooor__RecordType_OOOR__c" : "TESTRECORDTYPE_OOOR"}]',
      List<OutOfTheOfficeSettings_OOOR__mdt>.class
    );
    return taskActiveStringWithRecordType;
  }

  public static List<OutOfTheOfficeSettings_OOOR__mdt> createCMDTTaskStringNoRecordType() {
    // active cmdt record for task object with inactive feedpost and no record type
    List<OutOfTheOfficeSettings_OOOR__mdt> taskActiveStringWithRecordType = (List<OutOfTheOfficeSettings_OOOR__mdt>) Json.deserialize(
      '[{"ooor__ObjectAPIName_OOOR__c": "Task","ooor__Active_OOOR__c": true,"ooor__FeedPost_OOOR__c" : true, "ooor__FeedPostMessage_OOOR__c" : "This is the task feed", "ooor__FieldName_OOOR__c" : "Status", "ooor__QueryParameter_OOOR__c" : "!=", "ooor__QueryFilter_OOOR__c" : "Completed"}]',
      List<OutOfTheOfficeSettings_OOOR__mdt>.class
    );
    return taskActiveStringWithRecordType;
  }

  public static List<OutOfTheOfficeSettings_OOOR__mdt> createCMDTTaskBooleanWithRecordType() {
    // active cmdt record for task object with inactive feedpost and no record type
    List<OutOfTheOfficeSettings_OOOR__mdt> taskActiveBooleanWithRecordType = (List<OutOfTheOfficeSettings_OOOR__mdt>) Json.deserialize(
      '[{"ooor__ObjectAPIName_OOOR__c": "Task","ooor__Active_OOOR__c": true,"ooor__FeedPost_OOOR__c" : true, "ooor__FeedPostMessage_OOOR__c" : "This is the task feed", "ooor__FieldName_OOOR__c" : "IsReminderSet", "ooor__QueryParameter_OOOR__c" : "=", "ooor__QueryFilter_OOOR__c" : false, "ooor__RecordType_OOOR__c" : "TESTRECORDTYPE_OOOR"}]',
      List<OutOfTheOfficeSettings_OOOR__mdt>.class
    );
    return taskActiveBooleanWithRecordType;
  }

  public static List<OutOfTheOfficeSettings_OOOR__mdt> createCMDTCaseInactive() {
    // inactive cmdt record for case object
    List<OutOfTheOfficeSettings_OOOR__mdt> caseInactiveWithRecordType = (List<OutOfTheOfficeSettings_OOOR__mdt>) Json.deserialize(
      '[{"ooor__ObjectAPIName_OOOR__c": "ooor_OOOR__case","ooor__Active_OOOR__c": false,"ooor__FeedPost_OOOR__c" : true, "ooor__FeedPostMessage_OOOR__c" : "This is the case feed", "ooor__FieldName_OOOR__c" : "ooor__IsClosed", "ooor__QueryParameter_OOOR__c" : "=", "ooor__QueryFilter_OOOR__c" : false}]',
      List<OutOfTheOfficeSettings_OOOR__mdt>.class
    );

    return caseInactiveWithRecordType;
  }

  @isTest
  // This method will call the schedulable class which will be executing the batch
  // We are passing CMDT Settings here to the batch class, so it doesn't return null
  // However, this results in less code coverage while uploading - As this following line in OutOfOfficeBatchableOOOR.cls if (querySettings == null) will not be covered
  // Once clients add CMDT records in their code it will cover more lines of code in Batch
  static void callSchedulable() {
    List<Task> taskRecords = createTasks();
    insert taskRecords;

    User backupUser = createBackUpUser();
    insert backupUser;

    User timeOffUser = createTimeOffUser();
    insert timeOffUser;

    OutOfOfficeRequest_OOOR__c outOfOfficeRecord = createTimeOffRecord(
      timeOffUser.Id,
      backupUser.Id
    );
    insert outOfOfficeRecord;

    List<OutOfTheOfficeSettings_OOOR__mdt> cmdtTaskStringWithRecordType = createCMDTTaskStringWithRecordType();

    List<Task> reAssignTasksToTimeOffUser = reAssignTasksToTimeOffUser(
      timeOffUser.Id,
      90
    );
    update reAssignTasksToTimeOffUser;

    List<Task> timeoffUserTasks = [
      SELECT Id, OwnerId, Owner.Name
      FROM Task
      WHERE Owner.Name = 'timeOff'
    ];

    List<Task> backupUserTasks = [
      SELECT Id, OwnerId, Owner.Name
      FROM Task
      WHERE Owner.Name = 'backup'
    ];

    // 200 tasks have been created and 45 of them are owned by the user who is out of office. Prior to the batch run
    System.assertEquals(
      90,
      timeoffUserTasks.size(),
      'We expect 90 tasks where time off user is the owner'
    );

    // the backup user doesn't have any cases assigned to him prior to the batch run
    System.assertEquals(
      0,
      backupUserTasks.size(),
      'We expect 0 tasks for the backup user prior to the batch job'
    );

    Test.startTest();
    OutOfOfficeBatchableOOOR.querySettings = cmdtTaskStringWithRecordType;
    OutOfTheOfficeSchedulableOOOR sch = new OutOfTheOfficeSchedulableOOOR();
    sch.execute(null);
    Test.stopTest();

    List<Task> timeoffUserTasksAfterBatch = [
      SELECT Id, OwnerId, Owner.Name
      FROM Task
      WHERE Owner.Name = 'timeOff'
    ];

    List<Task> backupUserTasksAfterBatch = [
      SELECT Id, OwnerId, Owner.Name
      FROM Task
      WHERE Owner.Name = 'backup'
    ];

    // after the batch run, the user who is out of the office shouldn't own any cases himself any longer
    System.assertEquals(
      0,
      timeoffUserTasksAfterBatch.size(),
      'We expect 0 tasks for the timeoff user now'
    );

    // after the batch run, the backup user should have received the 45 cases
    System.assertEquals(
      90,
      backupUserTasksAfterBatch.size(),
      'We expect 90 tasks that have been re-assigned to the backup user now'
    );
  }
}
