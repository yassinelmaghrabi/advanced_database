-- University Enrollment System Database Schema
-- Member 1: Database Design

-- Create Database
USE master;
GO

-- Drop database if exists
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'UniversityDB')
BEGIN
    ALTER DATABASE UniversityDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE UniversityDB;
END
GO

-- Create database
CREATE DATABASE UniversityDB;
GO

USE UniversityDB;
GO

-- Create tables
-- Department table
CREATE TABLE Department (
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL,
    Building NVARCHAR(50),
    Budget DECIMAL(15,2) DEFAULT 0.00,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);
GO

-- Instructor table
CREATE TABLE Instructor (
    InstructorID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone NVARCHAR(20),
    HireDate DATE NOT NULL,
    DepartmentID INT REFERENCES Department(DepartmentID),
    IsAdjunct BIT DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);
GO

-- Course table
CREATE TABLE Course (
    CourseID INT IDENTITY(1,1) PRIMARY KEY,
    CourseCode NVARCHAR(10) UNIQUE NOT NULL,
    CourseName NVARCHAR(100) NOT NULL,
    Credits INT NOT NULL CHECK (Credits BETWEEN 1 AND 6),
    Description NVARCHAR(MAX),
    DepartmentID INT REFERENCES Department(DepartmentID),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);
GO

-- Student table
CREATE TABLE Student (
    StudentID INT IDENTITY(10000,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone NVARCHAR(20),
    DateOfBirth DATE,
    EnrollmentDate DATE NOT NULL DEFAULT GETDATE(),
    MajorDepartmentID INT REFERENCES Department(DepartmentID),
    GPA DECIMAL(3,2) DEFAULT 0.00 CHECK (GPA BETWEEN 0.00 AND 4.00),
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE()
);
GO

-- Student audit log table
CREATE TABLE StudentAuditLog (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL,
    OldFirstName NVARCHAR(50),
    OldLastName NVARCHAR(50),
    NewFirstName NVARCHAR(50),
    NewLastName NVARCHAR(50),
    ChangedBy NVARCHAR(100),
    ChangedDate DATETIME DEFAULT GETDATE()
);
GO

-- Academic Term table
CREATE TABLE AcademicTerm (
    TermID INT IDENTITY(1,1) PRIMARY KEY,
    TermName NVARCHAR(50) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    RegistrationStartDate DATE NOT NULL,
    RegistrationEndDate DATE NOT NULL,
    IsActive BIT DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT CHK_TermDates CHECK (EndDate > StartDate AND RegistrationEndDate > RegistrationStartDate)
);
GO

-- Course Offering table
CREATE TABLE CourseOffering (
    OfferingID INT IDENTITY(1,1) PRIMARY KEY,
    CourseID INT REFERENCES Course(CourseID),
    TermID INT REFERENCES AcademicTerm(TermID),
    InstructorID INT REFERENCES Instructor(InstructorID),
    Section NVARCHAR(10) NOT NULL,
    Schedule NVARCHAR(100),
    Location NVARCHAR(100),
    MaxEnrollment INT DEFAULT 30,
    CurrentEnrollment INT DEFAULT 0,
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_CourseOffering UNIQUE (CourseID, TermID, Section),
    CONSTRAINT CHK_Enrollment CHECK (CurrentEnrollment <= MaxEnrollment)
);
GO

-- Enrollment table
CREATE TABLE Enrollment (
    EnrollmentID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT REFERENCES Student(StudentID),
    OfferingID INT REFERENCES CourseOffering(OfferingID),
    EnrollmentDate DATE DEFAULT GETDATE(),
    Grade NVARCHAR(2),
    GradePoints DECIMAL(3,2),
    Status NVARCHAR(20) DEFAULT 'Enrolled', -- Enrolled, Dropped, Completed, Failed
    DiscountPercentage DECIMAL(5,2) DEFAULT 0.00,
    TuitionAmount DECIMAL(10,2) DEFAULT 0.00,
    PaymentStatus NVARCHAR(20) DEFAULT 'Pending',
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT CHK_Grade CHECK (Grade IN (NULL, 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'D-', 'F', 'W', 'I')),
    CONSTRAINT CHK_Discount CHECK (DiscountPercentage BETWEEN 0.00 AND 100.00),
    CONSTRAINT UQ_Enrollment UNIQUE (StudentID, OfferingID)
);
GO

-- Prerequisite table
CREATE TABLE Prerequisite (
    PrerequisiteID INT IDENTITY(1,1) PRIMARY KEY,
    CourseID INT REFERENCES Course(CourseID),
    RequiredCourseID INT REFERENCES Course(CourseID),
    MinimumGrade NVARCHAR(2) DEFAULT 'C',
    CreatedDate DATETIME DEFAULT GETDATE(),
    ModifiedDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_Prerequisite UNIQUE (CourseID, RequiredCourseID),
    CONSTRAINT CHK_NotSelf CHECK (CourseID <> RequiredCourseID)
);
GO

-- Create table for storing performance metrics
CREATE TABLE PerformanceMetrics (
    MetricID INT IDENTITY(1,1) PRIMARY KEY,
    QueryDescription NVARCHAR(255),
    ExecutionTime DECIMAL(10,4), -- in milliseconds
    ExecutionDate DATETIME DEFAULT GETDATE(),
    WithIndex BIT,
    EstimatedRows INT,
    ActualRows INT,
    IndexUsed NVARCHAR(100)
);
GO
