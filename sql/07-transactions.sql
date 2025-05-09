-- University Enrollment System - Transactions
-- Member 3: Transactions and Isolation Levels

USE UniversityDB;
GO

-- =============================================
-- 1. RegisterStudentWithTransaction
--    Demonstrates BEGIN TRAN, COMMIT, ROLLBACK
-- =============================================

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @StudentID INT = 10000; -- Replace with a valid StudentID
    DECLARE @OfferingID INT = 1;    -- Replace with a valid OfferingID

    -- Check if course is full
    IF EXISTS (
        SELECT 1
        FROM CourseOffering
        WHERE OfferingID = @OfferingID AND CurrentEnrollment >= MaxEnrollment
    )
    BEGIN
        RAISERROR('Enrollment failed: Course is full.', 16, 1);
    END

    -- Check prerequisites
    DECLARE @CourseID INT;
    SELECT @CourseID = CourseID FROM CourseOffering WHERE OfferingID = @OfferingID;

    IF dbo.CheckPrerequisites(@StudentID, @CourseID) = 0
    BEGIN
        RAISERROR('Enrollment failed: Prerequisites not met.', 16, 1);
    END

    -- Prevent duplicate enrollment
    IF EXISTS (
        SELECT 1
        FROM Enrollment e
        JOIN CourseOffering co ON e.OfferingID = co.OfferingID
        WHERE e.StudentID = @StudentID
        AND co.CourseID = @CourseID
        AND e.Status IN ('Enrolled', 'Completed')
    )
    BEGIN
        RAISERROR('Enrollment failed: Already enrolled in this course.', 16, 1);
    END

    -- Insert enrollment
    INSERT INTO Enrollment (
        StudentID, OfferingID, EnrollmentDate, Status,
        DiscountPercentage, TuitionAmount, PaymentStatus,
        CreatedDate, ModifiedDate
    )
    VALUES (
        @StudentID, @OfferingID, GETDATE(), 'Enrolled',
        0.00, dbo.CalculateTuition(@OfferingID, 0.00), 'Pending',
        GETDATE(), GETDATE()
    );

    -- Update enrollment count
    UPDATE CourseOffering
    SET CurrentEnrollment = CurrentEnrollment + 1
    WHERE OfferingID = @OfferingID;

    COMMIT TRANSACTION;
    PRINT 'Enrollment successful.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT 'Transaction failed.';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

-- =============================================
-- 2. Isolation Level Demo
--    Shows usage of READ COMMITTED / SERIALIZABLE
-- =============================================

-- Example: Set isolation level to SERIALIZABLE
-- Prevents phantom reads when checking and inserting enrollments

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;

-- Check current enrollment
SELECT CurrentEnrollment, MaxEnrollment
FROM CourseOffering
WHERE OfferingID = 1;

-- Simulate delay for concurrent enrollment attempt
WAITFOR DELAY '00:00:10';

-- Insert logic here would go next...

COMMIT TRANSACTION;
GO

