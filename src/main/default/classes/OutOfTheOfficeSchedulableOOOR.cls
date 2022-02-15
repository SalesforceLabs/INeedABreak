/*
Author: Demen Selcan
E-Mail: dselcan@salesforce.com
Last Updated: 4th Jul 2021
*/
public with sharing class OutOfTheOfficeSchedulableOOOR implements Schedulable {
  public void execute(SchedulableContext context) {
    OutOfOfficeBatchableOOOR OutOfTheOfficeBatchable = new OutOfOfficeBatchableOOOR();
    Id idBatch = Database.executeBatch(OutOfTheOfficeBatchable);
  }
}
