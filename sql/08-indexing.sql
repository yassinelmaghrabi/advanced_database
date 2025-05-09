-- University Enrollment System - Indexing
-- Member 3: Index Optimization

USE UniversityDB;
GO

-- ================================================
-- 1. Indexes on Foreign Key and Search Columns
-- ================================================

-- Student Table
CREATE NONCLUSTERED INDEX IX_Student_Email ON Student(Email);
CREATE NONCLUSTERED INDEX IX_Student_MajorDepartmentID ON Student(MajorDepartmentID);

-- Instructor Table
CREATE NONCLUSTERED INDEX IX_Instructor_DepartmentID ON Instructor(DepartmentID);

-- Course Table
CREATE NONCLUSTERED INDEX IX_Course_DepartmentID ON Course(DepartmentID);
CREATE NONCLUSTERED INDEX IX_Course_CourseCode ON Course(CourseCode);

-- CourseOffering Table
CREATE NONCLUSTERED INDEX IX_CourseOffering_CourseID_TermID ON CourseOffering(CourseID, TermID);
CREATE NONCLUSTERED INDEX IX_CourseOffering_InstructorID ON CourseOffering(InstructorID);

-- Enrollment Table
CREATE NONCLUSTERED INDEX IX_Enrollment_StudentID ON Enrollment(StudentID);
CREATE NONCLUSTERED INDEX IX_Enrollment_OfferingID ON Enrollment(OfferingID);
CREATE NONCLUSTERED INDEX IX_Enrollment_Status ON Enrollment(Status);

-- AcademicTerm Table
CREATE NONCLUSTERED INDEX IX_AcademicTerm_IsActive ON AcademicTerm(IsActive);

-- Prerequisite Table
CREATE NONCLUSTERED INDEX IX_Prerequisite_CourseID ON Prerequisite(CourseID);
CREATE NONCLUSTERED INDEX IX_Prerequisite_RequiredCourseID ON Prerequisite(RequiredCourseID);

-- ================================================
-- 2. Include Performance Metric Test (Optional)
-- ================================================

-- Sample performance comparison script:
-- Enable actual execution plan before running this!

-- Query without index
SELECT * FROM Student WHERE Email = 'sample@student.edu';

-- After creating index above, rerun and compare execution time
-- You can log comparisons into PerformanceMetrics table if desired.

-- Example logging
INSERT INTO PerformanceMetrics (
    QueryDescription, ExecutionTime, WithIndex, EstimatedRows, ActualRows, IndexUsed
)
VALUES (
    'Select Student by Email',
    1.2500, -- replace with real time measured via SET STATISTICS TIME
    1,
    1,      -- estimated rows
    1,      -- actual rows
    'IX_Student_Email'
);
GO

