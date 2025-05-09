-- University Enrollment System - Security & Permissions
-- Member 3: Roles and Access Control

USE UniversityDB;
GO

-- =======================================================
-- 1. Create Roles
-- =======================================================

-- Admin: Full access
CREATE ROLE Admin;
-- Instructor: Read access + limited update
CREATE ROLE Instructor;
-- Student: Read-only access to own data
CREATE ROLE Student;

-- =======================================================
-- 2. Create Sample Users (for demonstration)
-- =======================================================

-- WARNING: Replace or skip this section in production

CREATE LOGIN admin_user WITH PASSWORD = 'Admin123!';
CREATE USER admin_user FOR LOGIN admin_user;
EXEC sp_addrolemember 'Admin', 'admin_user';

CREATE LOGIN instructor_user WITH PASSWORD = 'Teach123!';
CREATE USER instructor_user FOR LOGIN instructor_user;
EXEC sp_addrolemember 'Instructor', 'instructor_user';

CREATE LOGIN student_user WITH PASSWORD = 'Student123!';
CREATE USER student_user FOR LOGIN student_user;
EXEC sp_addrolemember 'Student', 'student_user';

-- =======================================================
-- 3. Grant Permissions by Role
-- =======================================================

-- Admin: Full access
GRANT CONTROL ON DATABASE::UniversityDB TO Admin;

-- Instructor Permissions
GRANT SELECT, UPDATE ON dbo.CourseOffering TO Instructor;
GRANT SELECT ON dbo.Course TO Instructor;
GRANT SELECT ON dbo.Student TO Instructor;
GRANT SELECT ON dbo.Enrollment TO Instructor;
GRANT EXECUTE ON SCHEMA::dbo TO Instructor;

-- Student Permissions
GRANT SELECT ON dbo.Student TO Student;
GRANT SELECT ON dbo.Enrollment TO Student;
GRANT EXECUTE ON SCHEMA::dbo TO Student;

-- Optionally restrict Student to only view their own records using views or application logic

-- =======================================================
-- 4. Optional: Create Secure Schemas (advanced use)
-- =======================================================
-- CREATE SCHEMA secure AUTHORIZATION Admin;
-- Move sensitive tables to 'secure' and control schema access

GO

