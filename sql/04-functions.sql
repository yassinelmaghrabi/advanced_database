-- University Enrollment System Functions
-- Member 2: Functions, Procedures, and Triggers

USE UniversityDB;
GO

-- Scalar function to get course name by ID
CREATE OR ALTER FUNCTION GetCourseName(@CourseID INT)
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @CourseName NVARCHAR(100);
    
    SELECT @CourseName = CourseName
    FROM Course
    WHERE CourseID = @CourseID;
    
    RETURN ISNULL(@CourseName, 'Course Not Found');
END;
GO

-- Function to calculate GPA for a student
CREATE OR ALTER FUNCTION CalculateGPA(@StudentID INT)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @TotalPoints DECIMAL(10,2) = 0;
    DECLARE @TotalCredits INT = 0;
    DECLARE @GPA DECIMAL(3,2) = 0;
    
    SELECT 
        @TotalPoints = SUM(e.GradePoints * c.Credits),
        @TotalCredits = SUM(CASE WHEN e.GradePoints IS NOT NULL THEN c.Credits ELSE 0 END)
    FROM 
        Enrollment e
        JOIN CourseOffering co ON e.OfferingID = co.OfferingID
        JOIN Course c ON co.CourseID = c.CourseID
    WHERE 
        e.StudentID = @StudentID
        AND e.Status = 'Completed'
        AND e.GradePoints IS NOT NULL;
    
    -- Calculate GPA if there are completed courses with grades
    IF @TotalCredits > 0
        SET @GPA = ROUND(@TotalPoints / @TotalCredits, 2);
    
    RETURN @GPA;
END;
GO

-- Function to check if a student meets prerequisites for a course
CREATE OR ALTER FUNCTION CheckPrerequisites(@StudentID INT, @CourseID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @MeetsPrereqs BIT = 1;
    DECLARE @PrereqsCount INT = 0;
    DECLARE @PrereqsMet INT = 0;
    
    -- Count how many prerequisites the course has
    SELECT @PrereqsCount = COUNT(*)
    FROM Prerequisite
    WHERE CourseID = @CourseID;
    
    -- If no prerequisites, return true
    IF @PrereqsCount = 0
        RETURN 1;
    
    -- Count how many prerequisites the student has satisfied
    SELECT @PrereqsMet = COUNT(*)
    FROM Prerequisite p
    JOIN Course c ON p.RequiredCourseID = c.CourseID
    JOIN CourseOffering co ON c.CourseID = co.CourseID
    JOIN Enrollment e ON co.OfferingID = e.OfferingID
    WHERE 
        p.CourseID = @CourseID
        AND e.StudentID = @StudentID
        AND e.Status = 'Completed'
        AND (
            -- Check if the student's grade meets the minimum requirement
            (p.MinimumGrade = 'A' AND e.Grade = 'A') OR
            (p.MinimumGrade = 'B' AND e.Grade IN ('A', 'B', 'A-', 'B+')) OR
            (p.MinimumGrade = 'C' AND e.Grade IN ('A', 'B', 'C', 'A-', 'B+', 'B-', 'C+')) OR
            (p.MinimumGrade = 'D' AND e.Grade IN ('A', 'B', 'C', 'D', 'A-', 'B+', 'B-', 'C+', 'C-', 'D+', 'D-'))
        );
    
    -- Student meets prerequisites if they've satisfied all required courses
    IF @PrereqsMet = @PrereqsCount
        SET @MeetsPrereqs = 1;
    ELSE
        SET @MeetsPrereqs = 0;
    
    RETURN @MeetsPrereqs;
END;
GO

-- Function to calculate tuition for an enrollment
CREATE OR ALTER FUNCTION CalculateTuition(@OfferingID INT, @DiscountPercentage DECIMAL(5,2))
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @BaseTuition DECIMAL(10,2) = 350.00; -- Base tuition rate per credit
    DECLARE @Credits INT;
    DECLARE @TotalTuition DECIMAL(10,2);
    
    -- Get the credits for the course
    SELECT @Credits = c.Credits
    FROM CourseOffering co
    JOIN Course c ON co.CourseID = c.CourseID
    WHERE co.OfferingID = @OfferingID;
    
    -- Calculate total tuition
    SET @TotalTuition = @BaseTuition * @Credits;
    
    -- Apply discount if applicable
    IF @DiscountPercentage > 0
    BEGIN
        SET @TotalTuition = @TotalTuition * (1 - (@DiscountPercentage / 100.0));
    END
    
    RETURN ROUND(@TotalTuition, 2);
END;
GO

-- Function to get instructor load information
CREATE OR ALTER FUNCTION GetInstructorLoad(@InstructorID INT, @TermID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        COUNT(co.OfferingID) AS CourseCount,
        SUM(c.Credits) AS TotalCredits,
        SUM(co.CurrentEnrollment) AS TotalStudents
    FROM 
        CourseOffering co
        JOIN Course c ON co.CourseID = c.CourseID
    WHERE 
        co.InstructorID = @InstructorID
        AND co.TermID = @TermID
);
GO
