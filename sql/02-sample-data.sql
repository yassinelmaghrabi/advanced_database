-- University Enrollment System Sample Data
-- Member 1: Database Design and Queries

USE UniversityDB;
GO

-- Insert Departments
INSERT INTO Department (DepartmentName, Building, Budget)
VALUES 
('Computer Science', 'Tech Building A', 1500000.00),
('Mathematics', 'Science Hall', 1200000.00),
('Engineering', 'Engineering Complex', 2000000.00),
('Business', 'Business Center', 1800000.00),
('Psychology', 'Liberal Arts Building', 950000.00),
('Biology', 'Science Hall', 1350000.00),
('English', 'Liberal Arts Building', 850000.00),
('Physics', 'Science Hall', 1400000.00);
GO

-- Insert Instructors
INSERT INTO Instructor (FirstName, LastName, Email, Phone, HireDate, DepartmentID, IsAdjunct)
VALUES
('John', 'Smith', 'john.smith@university.edu', '555-123-4567', '2010-08-15', 1, 0),
('Emily', 'Johnson', 'emily.johnson@university.edu', '555-234-5678', '2015-01-20', 1, 0),
('Michael', 'Williams', 'michael.williams@university.edu', '555-345-6789', '2012-06-10', 2, 0),
('Sarah', 'Brown', 'sarah.brown@university.edu', '555-456-7890', '2018-08-01', 3, 0),
('David', 'Jones', 'david.jones@university.edu', '555-567-8901', '2014-09-15', 4, 0),
('Jennifer', 'Miller', 'jennifer.miller@university.edu', '555-678-9012', '2017-07-01', 5, 1),
('Robert', 'Davis', 'robert.davis@university.edu', '555-789-0123', '2013-05-20', 6, 0),
('Lisa', 'Garcia', 'lisa.garcia@university.edu', '555-890-1234', '2019-01-15', 7, 1),
('James', 'Wilson', 'james.wilson@university.edu', '555-901-2345', '2011-08-10', 8, 0),
('Patricia', 'Martinez', 'patricia.martinez@university.edu', '555-012-3456', '2016-03-01', 1, 1);
GO

-- Insert Courses
INSERT INTO Course (CourseCode, CourseName, Credits, Description, DepartmentID)
VALUES
('CS101', 'Introduction to Programming', 3, 'Basic programming concepts using Python', 1),
('CS202', 'Data Structures', 4, 'Advanced data structures and algorithms', 1),
('CS303', 'Database Systems', 4, 'Database design and SQL', 1),
('CS404', 'Software Engineering', 3, 'Software development methodologies', 1),
('MATH101', 'Calculus I', 4, 'Limits, derivatives, and integrals', 2),
('MATH202', 'Linear Algebra', 3, 'Vector spaces and linear transformations', 2),
('ENG101', 'Introduction to Engineering', 3, 'Overview of engineering disciplines', 3),
('ENG202', 'Circuit Analysis', 4, 'Basic electrical circuit analysis', 3),
('BUS101', 'Introduction to Business', 3, 'Business fundamentals and practices', 4),
('BUS202', 'Marketing Principles', 3, 'Marketing concepts and strategies', 4),
('PSYCH101', 'Introduction to Psychology', 3, 'Basic psychological principles', 5),
('BIO101', 'General Biology', 4, 'Introduction to biological concepts', 6),
('ENGL101', 'Composition', 3, 'Writing and rhetoric', 7),
('PHYS101', 'Physics I', 4, 'Mechanics and kinematics', 8);
GO

-- Insert Academic Terms
INSERT INTO AcademicTerm (TermName, StartDate, EndDate, RegistrationStartDate, RegistrationEndDate, IsActive)
VALUES
('Fall 2024', '2024-09-01', '2024-12-15', '2024-07-01', '2024-08-15', 0),
('Spring 2025', '2025-01-15', '2025-05-15', '2024-11-01', '2024-12-15', 1),
('Summer 2025', '2025-06-01', '2025-08-01', '2025-04-01', '2025-05-15', 0),
('Fall 2025', '2025-09-01', '2025-12-15', '2025-07-01', '2025-08-15', 0);
GO

-- Insert Students (30 sample students)
INSERT INTO Student (FirstName, LastName, Email, Phone, DateOfBirth, EnrollmentDate, MajorDepartmentID, GPA)
VALUES
('Alex', 'Thompson', 'alex.thompson@email.com', '555-111-2222', '2000-05-15', '2022-09-01', 1, 3.75),
('Jessica', 'Martin', 'jessica.martin@email.com', '555-222-3333', '2001-07-22', '2022-09-01', 1, 3.90),
('Brandon', 'Lee', 'brandon.lee@email.com', '555-333-4444', '2002-03-10', '2022-09-01', 2, 3.50),
('Sophia', 'Anderson', 'sophia.anderson@email.com', '555-444-5555', '2001-11-05', '2023-01-15', 3, 3.85),
('Tyler', 'Clark', 'tyler.clark@email.com', '555-555-6666', '2003-01-20', '2023-01-15', 4, 3.20),
('Emma', 'Rodriguez', 'emma.rodriguez@email.com', '555-666-7777', '2000-09-12', '2021-09-01', 5, 3.60),
('Noah', 'White', 'noah.white@email.com', '555-777-8888', '2002-06-30', '2023-01-15', 6, 3.40),
('Olivia', 'Harris', 'olivia.harris@email.com', '555-888-9999', '2001-04-25', '2022-01-15', 7, 3.95),
('William', 'Lewis', 'william.lewis@email.com', '555-999-0000', '2000-12-08', '2021-09-01', 8, 3.30),
('Ava', 'Walker', 'ava.walker@email.com', '555-000-1111', '2002-08-17', '2023-01-15', 1, 3.70),
('James', 'Hall', 'james.hall@email.com', '555-112-2233', '2001-02-14', '2022-09-01', 2, 3.25),
('Charlotte', 'Young', 'charlotte.young@email.com', '555-223-3344', '2000-10-31', '2021-09-01', 3, 3.80),
('Benjamin', 'King', 'benjamin.king@email.com', '555-334-4455', '2003-05-03', '2023-09-01', 4, 3.45),
('Mia', 'Wright', 'mia.wright@email.com', '555-445-5566', '2002-01-25', '2023-01-15', 5, 3.65),
('Ethan', 'Lopez', 'ethan.lopez@email.com', '555-556-6677', '2001-07-19', '2022-09-01', 6, 3.55),
('Amelia', 'Hill', 'amelia.hill@email.com', '555-667-7788', '2000-03-28', '2021-09-01', 7, 3.85),
('Daniel', 'Scott', 'daniel.scott@email.com', '555-778-8899', '2002-11-14', '2023-01-15', 8, 3.35),
('Isabella', 'Green', 'isabella.green@email.com', '555-889-9900', '2001-09-09', '2022-09-01', 1, 3.75),
('Matthew', 'Adams', 'matthew.adams@email.com', '555-990-0011', '2000-06-17', '2021-09-01', 2, 3.40),
('Abigail', 'Baker', 'abigail.baker@email.com', '555-001-1122', '2003-04-20', '2023-09-01', 3, 3.95),
('Henry', 'Gonzalez', 'henry.gonzalez@email.com', '555-113-2244', '2002-02-02', '2023-01-15', 4, 3.65),
('Elizabeth', 'Nelson', 'elizabeth.nelson@email.com', '555-224-3355', '2001-08-15', '2022-09-01', 5, 3.50),
('Alexander', 'Carter', 'alexander.carter@email.com', '555-335-4466', '2000-12-22', '2021-09-01', 6, 3.80),
('Victoria', 'Mitchell', 'victoria.mitchell@email.com', '555-446-5577', '2002-05-27', '2023-01-15', 7, 3.70),
('Michael', 'Perez', 'michael.perez@email.com', '555-557-6688', '2001-03-11', '2022-09-01', 8, 3.30),
('Grace', 'Roberts', 'grace.roberts@email.com', '555-668-7799', '2000-07-04', '2021-09-01', 1, 3.90),
('Joseph', 'Turner', 'joseph.turner@email.com', '555-779-8800', '2003-01-18', '2023-09-01', 2, 3.60),
('Chloe', 'Phillips', 'chloe.phillips@email.com', '555-880-9911', '2002-10-09', '2023-01-15', 3, 3.45),
('Samuel', 'Campbell', 'samuel.campbell@email.com', '555-991-0022', '2001-04-02', '2022-09-01', 4, 3.75),
('Zoey', 'Parker', 'zoey.parker@email.com', '555-002-1133', '2000-11-26', '2021-09-01', 5, 3.85);
GO

-- Insert Course Offerings
INSERT INTO CourseOffering (CourseID, TermID, InstructorID, Section, Schedule, Location, MaxEnrollment, CurrentEnrollment)
VALUES
-- Spring 2025 offerings
(1, 2, 1, 'A', 'MWF 9:00-10:15', 'Tech Building A 101', 30, 0),
(2, 2, 2, 'A', 'TTh 11:00-12:45', 'Tech Building A 205', 25, 0),
(3, 2, 1, 'A', 'MWF 13:00-14:15', 'Tech Building A 110', 25, 0),
(4, 2, 2, 'A', 'TTh 15:00-16:45', 'Tech Building A 210', 20, 0),
(5, 2, 3, 'A', 'MWF 8:00-9:15', 'Science Hall 120', 35, 0),
(6, 2, 3, 'A', 'TTh 13:00-14:45', 'Science Hall 220', 30, 0),
(7, 2, 4, 'A', 'MWF 10:30-11:45', 'Engineering Complex 110', 30, 0),
(8, 2, 4, 'A', 'TTh 9:00-10:45', 'Engineering Complex 220', 25, 0),
(9, 2, 5, 'A', 'MWF 14:30-15:45', 'Business Center 105', 40, 0),
(10, 2, 5, 'A', 'TTh 14:00-15:45', 'Business Center 205', 35, 0),
(11, 2, 6, 'A', 'MWF 11:00-12:15', 'Liberal Arts Building 110', 40, 0),
(12, 2, 7, 'A', 'TTh 10:00-11:45', 'Science Hall 230', 35, 0),
(13, 2, 8, 'A', 'MWF 13:30-14:45', 'Liberal Arts Building 210', 35, 0),
(14, 2, 9, 'A', 'TTh 13:00-14:45', 'Science Hall 140', 30, 0),
-- Additional sections for popular courses
(1, 2, 10, 'B', 'TTh 9:00-10:45', 'Tech Building A 102', 30, 0),
(5, 2, 3, 'B', 'TTh 8:00-9:45', 'Science Hall 125', 35, 0),
(9, 2, 5, 'B', 'TTh 16:00-17:45', 'Business Center 110', 40, 0),
(11, 2, 6, 'B', 'MWF 15:00-16:15', 'Liberal Arts Building 120', 40, 0);
GO

-- Insert some prerequisites
INSERT INTO Prerequisite (CourseID, RequiredCourseID, MinimumGrade)
VALUES
(2, 1, 'C'), -- Data Structures requires Intro to Programming
(3, 1, 'C'), -- Database Systems requires Intro to Programming
(4, 2, 'C'), -- Software Engineering requires Data Structures
(4, 3, 'C'), -- Software Engineering requires Database Systems
(6, 5, 'C'), -- Linear Algebra requires Calculus I
(8, 7, 'C'), -- Circuit Analysis requires Intro to Engineering
(10, 9, 'C'); -- Marketing Principles requires Intro to Business
GO

-- Enroll students in courses (Spring 2025)
-- First update the stored procedure to properly handle enrollment counts
-- This will be done in a separate enrollment script to simulate registrations
