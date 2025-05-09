-- University Enrollment System Stored Procedures
-- Member 2: Functions, Procedures, and Triggers

USE UniversityDB;
GO

-- Stored procedure to apply enrollment discount
CREATE OR ALTER PROCEDURE ApplyEnrollmentDiscount
    @EnrollmentID INT,
    @DiscountPercentage DECIMAL(5,2),
    @DiscountReason NVARCHAR(100) = NULL,
    @ModifiedBy NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Input validation
    IF @DiscountPercentage < 0 OR @DiscountPercentage > 100
    BEGIN
        RAISERROR('Discount percentage must be between 0 and 100', 16, 1);
        RETURN;
    END
    
    -- Check if enrollment exists
    IF NOT EXISTS (SELECT 1 FROM Enrollment WHERE EnrollmentID = @EnrollmentID)
    BEGIN
        RAISERROR('Enrollment record not found', 16, 1);
        RETURN;
    END
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Get offering ID for the enrollment to recalculate tuition
        DECLARE @OfferingID INT;
        SELECT @OfferingID = OfferingID FROM Enrollment WHERE EnrollmentID = @EnrollmentID;
        
        -- Update discount and recalculate tuition
        UPDATE Enrollment
        SET 
            DiscountPercentage = @DiscountPercentage,
            TuitionAmount = dbo.CalculateTuition(@OfferingID, @DiscountPercentage),
            ModifiedDate = GETDATE()
        WHERE 
            EnrollmentID = @EnrollmentID;
        
        -- Log the discount application
        INSERT INTO EnrollmentAuditLog (EnrollmentID, ChangeType, OldValue, NewValue, ChangeReason, ChangedBy, ChangedDate)
        VALUES (@EnrollmentID, 'Discount Applied', '0.00', CAST(@DiscountPercentage AS NVARCHAR(10)), 
                @DiscountReason, @ModifiedBy, GETDATE());
        
        COMMIT TRANSACTION;
        
        PRINT 'Discount of ' + CAST(@DiscountPercentage AS NVARCHAR(10)) + '% applied successfully.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- Create EnrollmentAuditLog table if it doesn't exist (referenced by the procedure above)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'EnrollmentAuditLog')
BEGIN
    CREATE TABLE EnrollmentAuditLog (
        LogID INT IDENTITY(1,1) PRIMARY KEY,
        EnrollmentID INT NOT NULL,
        ChangeType NVARCHAR(50) NOT NULL,
        OldValue NVARCHAR(MAX),
        NewValue NVARCHAR(MAX),
        ChangeReason NVARCHAR(255),
        ChangedBy NVARCHAR(100),
        ChangedDate DATETIME DEFAULT GETDATE()
    );
END
GO

-- Stored procedure to register a student for a course
CREATE OR ALTER PROCEDURE RegisterStudent
    @StudentID INT,
    @OfferingID INT,
    @DiscountPercentage DECIMAL(5,2) = 0.00,
    @Output NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Input validation
    IF NOT EXISTS (SELECT 1 FROM Student WHERE StudentID = @StudentID)
    BEGIN
        SET @Output = 'Student not found';
        RETURN -1;
    END
    
    IF NOT EXISTS (SELECT 1 FROM CourseOffering WHERE OfferingID = @OfferingID)
    BEGIN
        SET @Output = 'Course offering not found';
        RETURN -2;
    END
    
    -- Check if the student is already enrolled in this course offering
    IF EXISTS (SELECT 1 FROM Enrollment WHERE StudentID = @StudentID AND OfferingID = @OfferingID)
    BEGIN
        SET @Output = 'Student is already enrolled in this course';
        RETURN -3;
    END
    
    -- Get course information
    DECLARE @CourseID INT;
    DECLARE @TermID INT;
    DECLARE @CurrentEnrollment INT;
    DECLARE @MaxEnrollment INT;
    
    SELECT 
        @CourseID = co.CourseID,
        @TermID = co.TermID,
        @CurrentEnrollment = co.CurrentEnrollment,
        @MaxEnrollment = co.MaxEnrollment
    FROM 
        CourseOffering co
    WHERE 
        co.OfferingID = @OfferingID;
    
    -- Check if there are available seats
    IF @CurrentEnrollment >= @MaxEnrollment
    BEGIN
        SET @Output = 'Course is full';
        RETURN -4;
    END
    
    -- Check prerequisites
    IF dbo.CheckPrerequisites(@StudentID, @CourseID) = 0
    BEGIN
        SET @Output = 'Student does not meet course prerequisites';
        RETURN -5;
    END
    
    -- Check if term is active for registration
    DECLARE @IsActive BIT;
    DECLARE @RegEndDate DATE;
    
    SELECT 
        @IsActive = IsActive,
        @RegEndDate = RegistrationEndDate
    FROM 
        AcademicTerm
    WHERE 
        TermID = @TermID;
    
    IF @IsActive = 0 OR GETDATE() > @RegEndDate
    BEGIN
        SET @Output = 'Registration is closed for this term';
        RETURN -6;
    END
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Calculate tuition amount
        DECLARE @TuitionAmount DECIMAL(10,2);
        SET @TuitionAmount = dbo.CalculateTuition(@OfferingID, @DiscountPercentage);
        
        -- Insert enrollment record
        INSERT INTO Enrollment (
            StudentID, 
            OfferingID, 
            EnrollmentDate, 
            Status, 
            DiscountPercentage, 
            TuitionAmount, 
            PaymentStatus
        )
        VALUES (
            @StudentID, 
            @OfferingID, 
            GETDATE(), 
            'Enrolled', 
            @DiscountPercentage, 
            @TuitionAmount, 
            'Pending'
        );
        
        -- Update current enrollment count
        UPDATE CourseOffering
        SET CurrentEnrollment = CurrentEnrollment + 1
        WHERE OfferingID = @OfferingID;
        
        COMMIT TRANSACTION;
        
        SET @Output = 'Student successfully registered for the course';
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SET @Output = 'Error: ' + ERROR_MESSAGE();
        RETURN -99;
    END CATCH;
END;
GO

-- Stored procedure to drop a course
CREATE OR ALTER PROCEDURE DropCourse
    @EnrollmentID INT,
    @Reason NVARCHAR(255) = NULL,
    @Output NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Input validation
    IF NOT EXISTS (SELECT 1 FROM Enrollment WHERE EnrollmentID = @EnrollmentID)
    BEGIN
        SET @Output = 'Enrollment record not found';
        RETURN -1;
    END
    
    -- Get enrollment information
    DECLARE @StudentID INT;
    DECLARE @OfferingID INT;
    DECLARE @Status NVARCHAR(20);
    DECLARE @EnrollmentDate DATE;
    DECLARE @TermID INT;
    DECLARE @TermStartDate DATE;
    
    SELECT 
        @StudentID = e.StudentID,
        @OfferingID = e.OfferingID,
        @Status = e.Status,
        @EnrollmentDate = e.EnrollmentDate
    FROM 
        Enrollment e
    WHERE 
        e.EnrollmentID = @EnrollmentID;
    
    -- Check if course is already dropped
    IF @Status = 'Dropped'
    BEGIN
        SET @Output = 'Course has already been dropped';
        RETURN -2;
    END
    
    -- Get term information
    SELECT 
        @TermID = co.TermID,
        @TermStartDate = at.StartDate
    FROM 
        CourseOffering co
        JOIN AcademicTerm at ON co.TermID = at.TermID
    WHERE 
        co.OfferingID = @OfferingID;
    
    -- Determine if it's a withdrawal (after term start) or drop (before term start)
    DECLARE @NewStatus NVARCHAR(20);
    DECLARE @Grade NVARCHAR(2);
    
    IF GETDATE() > @TermStartDate
    BEGIN
        SET @NewStatus = 'Withdrawn';
        SET @Grade = 'W';
    END
    ELSE
    BEGIN
        SET @NewStatus = 'Dropped';
        SET @Grade = NULL;
    END
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Update enrollment status
        UPDATE Enrollment
        SET 
            Status = @NewStatus,
            Grade = @Grade,
            ModifiedDate = GETDATE()
        WHERE 
            EnrollmentID = @EnrollmentID;
        
        -- Update course offering enrollment count
        UPDATE CourseOffering
        SET CurrentEnrollment = CurrentEnrollment - 1
        WHERE OfferingID = @OfferingID;
        
        -- Log the drop/withdrawal
        INSERT INTO EnrollmentAuditLog (EnrollmentID, ChangeType, OldValue, NewValue, ChangeReason, ChangedBy, ChangedDate)
        VALUES (@EnrollmentID, 'Status Change', 'Enrolled', @NewStatus, @Reason, 'System', GETDATE());
        
        COMMIT TRANSACTION;
        
        SET @Output = 'Course ' + @NewStatus + ' successfully';
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SET @Output = 'Error: ' + ERROR_MESSAGE();
        RETURN -99;
    END CATCH;
END;
GO

-- Stored procedure to assign grades
CREATE OR ALTER PROCEDURE AssignGrade
    @EnrollmentID INT,
    @Grade NVARCHAR(2),
    @AssignedBy NVARCHAR(100),
    @Output NVARCHAR(255) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Input validation
    IF NOT EXISTS (SELECT 1 FROM Enrollment WHERE EnrollmentID = @EnrollmentID)
    BEGIN
        SET @Output = 'Enrollment record not found';
        RETURN -1;
    END
    
    -- Validate grade
    IF @Grade NOT IN ('A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'D-', 'F', 'W', 'I')
    BEGIN
        SET @Output = 'Invalid grade. Must be A, A-, B+, B, B-, C+, C, C-, D+, D, D-, F, W, or I';
        RETURN -2;
    END
    
    -- Calculate grade points
    DECLARE @GradePoints DECIMAL(3,2);
    
    SET @GradePoints = 
        CASE @Grade
            WHEN 'A' THEN 4.00
            WHEN 'A-' THEN 3.67
            WHEN 'B+' THEN 3.33
            WHEN 'B' THEN 3.00
            WHEN 'B-' THEN 2.67
            WHEN 'C+' THEN 2.33
            WHEN 'C' THEN 2.00
            WHEN 'C-' THEN 1.67
            WHEN 'D+' THEN 1.33
            WHEN 'D' THEN 1.00
            WHEN 'D-' THEN 0.67
            WHEN 'F' THEN 0.00
            ELSE NULL -- W and I don't have grade points
        END;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Get old grade for audit log
        DECLARE @OldGrade NVARCHAR(2);
        SELECT @OldGrade = Grade FROM Enrollment WHERE EnrollmentID = @EnrollmentID;
        
        -- Update enrollment with grade
        UPDATE Enrollment
        SET 
            Grade = @Grade,
            GradePoints = @GradePoints,
            Status = CASE WHEN @Grade = 'I' THEN 'Incomplete' WHEN @Grade = 'W' THEN 'Withdrawn' ELSE 'Completed' END,
            ModifiedDate = GETDATE()
        WHERE 
            EnrollmentID = @EnrollmentID;
        
        -- Log the grade assignment
        INSERT INTO EnrollmentAuditLog (EnrollmentID, ChangeType, OldValue, NewValue, ChangeReason, ChangedBy, ChangedDate)
        VALUES (@EnrollmentID, 'Grade Assignment', ISNULL(@OldGrade, 'NULL'), @Grade, 'Grade Entry', @AssignedBy, GETDATE());
        
        COMMIT TRANSACTION;
        
        -- Update student GPA if applicable
        IF @Grade NOT IN ('W', 'I')
        BEGIN
            DECLARE @StudentID INT;
            SELECT @StudentID = StudentID FROM Enrollment WHERE EnrollmentID = @EnrollmentID;
            
            DECLARE @NewGPA DECIMAL(3,2);
            SET @NewGPA = dbo.CalculateGPA(@StudentID);
            
            UPDATE Student
            SET GPA = @NewGPA
            WHERE StudentID = @StudentID;
        END
        
        SET @Output = 'Grade assigned successfully';
        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        SET @Output = 'Error: ' + ERROR_MESSAGE();
        RETURN -99;
    END CATCH;
END;
GO
