-- University Enrollment System Views
-- Member 1: Database Design and Queries

USE UniversityDB;
GO

-- Create view for student progress
CREATE OR ALTER VIEW StudentProgressView
AS
SELECT 
    s.StudentID,
    s.FirstName + ' ' + s.LastName AS StudentName,
    s.Email,
    d.DepartmentName AS Major,
    c.CourseCode,
    c.CourseName,
    e.Grade,
    e.GradePoints,
    co.TermID,
    at.TermName,
    c.Credits,
    e.Status
FROM 
    Student s
    JOIN Enrollment e ON s.StudentID = e.StudentID
    JOIN CourseOffering co ON e.OfferingID = co.OfferingID
    JOIN Course c ON co.CourseID = c.CourseID
    JOIN Department d ON s.MajorDepartmentID = d.DepartmentID
    JOIN AcademicTerm at ON co.TermID = at.TermID;
GO

-- Create view for instructor teaching load
CREATE OR ALTER VIEW InstructorLoadView
AS
SELECT 
    i.InstructorID,
    i.FirstName + ' ' + i.LastName AS InstructorName,
    i.Email,
    d.DepartmentName,
    at.TermName,
    COUNT(co.OfferingID) AS CourseCount,
    SUM(c.Credits) AS TotalCredits,
    SUM(co.CurrentEnrollment) AS TotalStudents
FROM 
    Instructor i
    JOIN Department d ON i.DepartmentID = d.DepartmentID
    JOIN CourseOffering co ON i.InstructorID = co.InstructorID
    JOIN Course c ON co.CourseID = c.CourseID
    JOIN AcademicTerm at ON co.TermID = at.TermID
GROUP BY 
    i.InstructorID, i.FirstName, i.LastName, i.Email, d.DepartmentName, at.TermName;
GO

-- Create view for available courses (with seats remaining)
CREATE OR ALTER VIEW AvailableCoursesView
AS
SELECT 
    co.OfferingID,
    c.CourseCode,
    c.CourseName,
    c.Credits,
    d.DepartmentName,
    i.FirstName + ' ' + i.LastName AS InstructorName,
    co.Section,
    co.Schedule,
    co.Location,
    at.TermName,
    co.MaxEnrollment,
    co.CurrentEnrollment,
    (co.MaxEnrollment - co.CurrentEnrollment) AS AvailableSeats
FROM 
    CourseOffering co
    JOIN Course c ON co.CourseID = c.CourseID
    JOIN Department d ON c.DepartmentID = d.DepartmentID
    JOIN Instructor i ON co.InstructorID = i.InstructorID
    JOIN AcademicTerm at ON co.TermID = at.TermID
WHERE
    (co.MaxEnrollment - co.CurrentEnrollment) > 0
    AND at.IsActive = 1;
GO

-- Create view for department statistics
CREATE OR ALTER VIEW DepartmentStatsView
AS
SELECT 
    d.DepartmentID,
    d.DepartmentName,
    d.Building,
    COUNT(DISTINCT c.CourseID) AS TotalCourses,
    COUNT(DISTINCT i.InstructorID) AS TotalInstructors,
    COUNT(DISTINCT s.StudentID) AS TotalStudents,
    ROUND(AVG(CASE WHEN s.GPA IS NOT NULL THEN s.GPA ELSE NULL END), 2) AS AverageStudentGPA
FROM 
    Department d
    LEFT JOIN Course c ON d.DepartmentID = c.DepartmentID
    LEFT JOIN Instructor i ON d.DepartmentID = i.DepartmentID
    LEFT JOIN Student s ON d.DepartmentID = s.MajorDepartmentID
GROUP BY 
    d.DepartmentID, d.DepartmentName, d.Building;
GO
