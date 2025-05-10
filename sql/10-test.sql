
USE UniversityDB;
GO

-- *************
-- Test Script for University Course Enrollment & Management System
-- *************

-- Test 9: Verify Permissions
PRINT '---- Test 9: Verify Permissions ----';

-- Ensure the login exists (this requires sufficient privileges)
-- If TestLogin does not exist, create it. You may need to use an existing SQL Server login.

-- Check if the login already exists
IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'TestLogin')
BEGIN
    -- Create a login if it does not exist
    CREATE LOGIN TestLogin WITH PASSWORD = 'StrongPassword123!';
END

-- Create a user for the login in the current database
-- Check if the user already exists
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'TestUser')
BEGIN
    CREATE USER TestUser FOR LOGIN TestLogin;
END

-- Grant permissions to the user
GRANT SELECT, INSERT ON dbo.Student TO TestUser;

-- Attempt SELECT and INSERT (should work for TestUser)
EXECUTE AS USER = 'TestUser';
SELECT * FROM dbo.Student;

-- Check if the email already exists to prevent duplicates
IF NOT EXISTS (SELECT 1 FROM dbo.Student WHERE Email = 'testuser@example.com')
BEGIN
    -- Insert a record (this should work for TestUser)
    INSERT INTO dbo.Student (FirstName, LastName, DateOfBirth, EnrollmentDate, Email) 
    VALUES ('Test', 'User', '2001-03-15', GETDATE(), 'testuser@example.com');
END
ELSE
BEGIN
    PRINT 'Email already exists. Skipping insert.';
END

-- Attempt DELETE (should fail)
BEGIN TRY
    DELETE FROM dbo.Student WHERE StudentID = 2;
END TRY
BEGIN CATCH
    PRINT 'DELETE Permission Denied: ' + ERROR_MESSAGE();
END CATCH;

-- Revert back to the original execution context
REVERT;

-- *************
-- Test 1: Verify Table Creation and Data Insertion
PRINT '---- Test 1: Verify Table Creation and Data Insertion ----';
SELECT * FROM Student;
SELECT * FROM Course;
SELECT * FROM Enrollment;
SELECT * FROM Instructor;
SELECT * FROM CourseOffering;

-- *************
-- Test 2: Verify Views
PRINT '---- Test 2: Verify Views ----';

-- Test Student Progress View
SELECT * FROM StudentProgressView;

-- Test Instructor Load View
SELECT * FROM InstructorLoadView;

-- *************
-- Test 3: Verify Scalar Function
PRINT '---- Test 3: Verify Scalar Function ----';

-- Test GetCourseName function
DECLARE @CourseID INT = 1;
SELECT dbo.GetCourseName(@CourseID) AS CourseName;

-- *************
-- Test 4: Verify Stored Procedure
PRINT '---- Test 4: Verify Stored Procedure ----';

-- Apply a discount to an enrollment and check the result
DECLARE @EnrollmentID INT = 1;
DECLARE @Discount DECIMAL(5, 2) = 10.00; -- 10% discount
DECLARE @ModifiedBy NVARCHAR(100) = 'AdminUser';
DECLARE @DiscountReason NVARCHAR(100) = 'Scholarship';

EXEC ApplyEnrollmentDiscount
    @EnrollmentID = @EnrollmentID,
    @DiscountPercentage = @Discount,
    @DiscountReason = @DiscountReason,
    @ModifiedBy = @ModifiedBy;

-- *************
-- Test 5: Verify AFTER UPDATE Trigger
PRINT '---- Test 5: Verify AFTER UPDATE Trigger ----';

-- Update student name to test logging of name change
UPDATE Student
SET FirstName = 'Johnathan'
WHERE StudentID = 1;

-- *************
-- Test 7: Verify Transaction Handling (with error)
PRINT '---- Test 7: Verify Transaction Handling (with error) ----';

BEGIN TRY
    BEGIN TRANSACTION;
    -- Try to update the first student's last name, simulate error afterward
    UPDATE Student
    SET LastName = 'DoeUpdated'
    WHERE StudentID = 1;

    -- Simulate error
    THROW 50000, 'Error occurred in transaction', 1;

    COMMIT;  -- Won't execute due to error
END TRY
BEGIN CATCH
    ROLLBACK;  -- Rollback if error occurs
    PRINT 'Transaction Rolled Back: ' + ERROR_MESSAGE();
END CATCH;
-- *************
-- Test 8: Verify Index Creation and Performance
PRINT '---- Test 8: Verify Index Creation and Performance ----';

-- Perform a search to demonstrate indexing on LastName
SELECT * FROM Student WHERE LastName = 'Doe';

-- *************
-- Test 10: Check if all records and relationships are intact
PRINT '---- Test 10: Verify Integrity of Relationships ----';

-- Check Students with Enrollments
SELECT s.StudentID, s.FirstName, s.LastName, e.OfferingID, c.CourseName
FROM Student s
JOIN Enrollment e ON s.StudentID = e.StudentID
JOIN CourseOffering co ON e.OfferingID = co.OfferingID
JOIN Course c ON co.CourseID = c.CourseID;

-- *************
-- End of Test Script
-- *************