/*
Author: Demen Selcan
E-Mail: dselcan@salesforce.com
Last Updated: 27th Jun 2021
*/

@isTest
public class TestDataFactoryOOOR {
  public static List<Case> getCases(
    String Subject,
    String Origin,
    Integer NumberOfRecords
  ) {
    List<Case> cases = new List<Case>();
    for (Integer i = 0; i <= NumberOfRecords; i++) {
      Case cs = new Case();
      cs.Subject = Subject + i;
      cs.Origin = Origin;
      cases.add(cs);
      i++;
    }
    return cases;
  }

  public static List<Task> getTasks(
    String Subject,
    String Status,
    String Priority,
    Boolean IsReminderSet,
    Integer NumberOfRecords
  ) {
    List<Task> tasks = new List<Task>();
    Id taskRecordTypeId = [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE SobjectType = 'Task' AND DeveloperName = 'TESTRECORDTYPE_OOOR'
      LIMIT 1
    ]
    .Id;
    for (Integer i = 0; i <= NumberOfRecords; i++) {
      Task tsk = new Task();
      tsk.Subject = Subject + i;
      tsk.Status = Status;
      tsk.IsReminderSet = IsReminderSet;
      tsk.RecordTypeId = taskRecordTypeId;
      tsk.Priority = Priority;
      tasks.add(tsk);
      i++;
    }
    return tasks;
  }

  public static OutOfOfficeRequest_OOOR__c getOutOfOfficeRequestRecords(
    Id PersonTakingTimeOff,
    Id BackUpUser,
    String Status,
    Date StartDate,
    Date EndDate
  ) {
    OutOfOfficeRequest_OOOR__c oooRequest = new OutOfOfficeRequest_OOOR__c();
    oooRequest.PersonTakingTimeOff_OOOR__c = PersonTakingTimeOff;
    oooRequest.Status_OOOR__c = Status;
    oooRequest.BackupUser_OOOR__c = BackUpUser;
    oooRequest.StartDate_OOOR__c = StartDate;
    oooRequest.EndDate_OOOR__c = EndDate;

    return oooRequest;
  }
  public static User generateUser(
    String profileName,
    String lastName,
    String email,
    String userName,
    String companyName,
    String title,
    String alias
  ) {
    User u = new User(
      ProfileId = [SELECT Id FROM Profile WHERE Name = :profileName]
      .Id,
      LastName = lastName,
      Email = email,
      Username = userName,
      CompanyName = companyName,
      Title = title,
      Alias = alias,
      TimeZoneSidKey = 'America/Los_Angeles',
      EmailEncodingKey = 'UTF-8',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US'
    );
    return u;
  }
}
