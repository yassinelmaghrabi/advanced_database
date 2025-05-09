-- University Enrollment System Triggers
-- Member 2: Functions, Procedures, and Triggers

USE UniversityDB;
GO

-- AFTER UPDATE trigger to log student name changes
CREATE OR ALTER TRIGGER trg_StudentNameChange
ON Student
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Only log changes to first or last names
    IF UPDATE(FirstName) OR UPDATE(LastName)
    BEGIN
        INSERT INTO StudentAuditLog (
            StudentID,
            OldFirstName,
            OldLastName,
            NewFirstName,
            NewLastName,
            ChangedBy,
            ChangedDate
        )
        SELECT
            i.StudentID,
            d.FirstName,
            d.LastName,
            i.FirstName,
            i.LastName,
            SYSTEM_USER,
            GETDATE()
        FROM
            inserted i
            JOIN deleted d ON i.StudentID = d.StudentID
        WHERE
            i.FirstName <> d.FirstName OR i.LastName <> d.LastName;
        
        PRINT 'Student name changes have been logged.';
    END
END;
GO

-- INSTEAD OF trigger for enrollment handling
CREATE OR ALTER TRIGGER trg_EnrollmentInsteadOfInsert
ON Enrollment
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if any offering is full
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN CourseOffering co ON i.OfferingID = co.OfferingID
        WHERE co.CurrentEnrollment >= co.MaxEnrollment
    )
    BEGIN
        RAISERROR('Unable to complete enrollment: one or more selected courses are full.', 16, 1);
        RETURN;
    END
    
    -- Check for prerequisite requirements
    DECLARE @PrereqCheckFailed BIT = 0;
    DECLARE @FailedStudentID INT;
    DECLARE @FailedCourseID INT;
    
    SELECT TOP 1
        @PrereqCheckFailed = 1,
        @FailedStudentID = i.StudentID,
        @FailedCourseID = co.CourseID
    FROM
        inserted i
        JOIN CourseOffering co ON i.OfferingID = co.OfferingID
    WHERE
        dbo.CheckPrerequisites(i.StudentID, co.CourseID) = 0;
    
    IF @PrereqCheckFailed = 1
    BEGIN
        DECLARE @CourseCode NVARCHAR(10);
        SELECT @CourseCode = CourseCode FROM Course WHERE CourseID = @FailedCourseID;
        
        RAISERROR('Student ID %d does not meet prerequisites for course %s.', 16, 1, @FailedStudentID, @CourseCode);
        RETURN;
    END
    
    -- Check if student is already enrolled in the course for the term
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN CourseOffering co1 ON i.OfferingID = co1.OfferingID
        JOIN CourseOffering co2 ON co1.CourseID = co2.CourseID AND co1.TermID = co2.TermID
        JOIN Enrollment e ON e.OfferingID = co2.OfferingID AND e.StudentID = i.StudentID
        WHERE e.Status IN ('Enrolled', 'Completed')
    )
    BEGIN
        RAISERROR('Student is already enrolled in this course for the current term.', 16, 1);
        RETURN;
    END
    
    -- All validations passed, proceed with the actual insert
    INSERT INTO Enrollment (
        StudentID,
        OfferingID,
        EnrollmentDate,
        Grade,
        GradePoints,
        Status,
        DiscountPercentage,
        TuitionAmount,
        PaymentStatus,
        CreatedDate,
        ModifiedDate
    )
    SELECT
        i.StudentID,
        i.OfferingID,
        ISNULL(i.EnrollmentDate, GETDATE()),
        i.Grade,
        i.GradePoints,
        ISNULL(i.Status, 'Enrolled'),
        ISNULL(i.DiscountPercentage, 0.00),
        ISNULL(i.TuitionAmount, dbo.CalculateTuition(i.OfferingID, ISNULL(i.DiscountPercentage, 0.00))),
        ISNULL(i.PaymentStatus, 'Pending'),
        GETDATE(),
        GETDATE()
    FROM
        inserted i;
    
    -- Update course offering enrollment counts
    UPDATE co
    SET co.CurrentEnrollment = co.CurrentEnrollment + 1
    FROM CourseOffering co
    JOIN inserted i ON co.OfferingID = i.OfferingID;
    
    PRINT 'Enrollment processed successfully.';
END;
GO

-- AFTER UPDATE trigger to maintain enrollment counts when status changes
CREATE OR ALTER TRIGGER trg_EnrollmentStatusChange
ON Enrollment
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Check if status has changed and adjust enrollment counts
    IF UPDATE(Status)
    BEGIN
        -- Decrease course enrollment count when student drops or withdraws
        UPDATE co
        SET co.CurrentEnrollment = co.CurrentEnrollment - 1
        FROM CourseOffering co
        JOIN inserted i ON co.OfferingID = i.OfferingID
        JOIN deleted d ON i.EnrollmentID = d.EnrollmentID
        WHERE
            d.Status IN ('Enrolled') AND i.Status IN ('Dropped', 'Withdrawn');

        -- Increase course enrollment count if a student re-enrolls
        UPDATE co
        SET co.CurrentEnrollment = co.CurrentEnrollment + 1
        FROM CourseOffering co
        JOIN inserted i ON co.OfferingID = i.OfferingID
        JOIN deleted d ON i.EnrollmentID = d.EnrollmentID
        WHERE
            d.Status IN ('Dropped', 'Withdrawn') AND i.Status = 'Enrolled';

        PRINT 'Enrollment status changes have been processed.';
    END
END;
GO

-- End of trigger definitions for University Enrollment System

