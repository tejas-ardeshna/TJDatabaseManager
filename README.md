# TJDatabaseManager
FMDB database wrapper

## Features

- [x] Execute update
- [x] Execute quaries
- [x] Execute batch operations
- [x] Database versoning

## Usage example

### Copy Database
```swift
TJDatabaseManager.databaseManager.copyDatabaseIfNeeded()
```

### Execute select query
```swift
TJDatabaseManager.databaseManager.execute("Select * from tblUser")
```

### Execute batch operations
```swift
TJDatabaseManager.databaseManager.executeBatchOperations(["Select * from tblUser", "Select * from device", "update syncDate set syncDate = date where userId = 123", "insert into syncDate VALUES(123,date)"])
```
