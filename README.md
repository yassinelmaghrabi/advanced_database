
````markdown
# University Course Enrollment System

This is a University Course Enrollment System built using SQL Server, designed for managing students, courses, enrollments, and related functionalities. The system supports features like enrolling students, applying discounts, checking prerequisites, calculating tuition, and assigning grades.

## Requirements

- Docker
- SQL Server
- SQL Server Command-Line Tools (`sqlcmd`)

## Setup

### 1. Clone the Repository

Clone this repository to your local machine:
````

### 2. Run the Application with Docker

Build and run the SQL Server container using Docker. The Docker configuration file `docker-compose.yml` will handle this.

```bash
docker-compose up -d
```

This will set up SQL Server inside a Docker container, along with all required tables, functions, stored procedures, and data.

### 3. Connect to SQL Server

Once the container is up and running, connect to SQL Server using the `sqlcmd` tool. You can do this by running the following command:

```bash
docker exec -it <container-id> /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'University_P@ssw0rd' -C
```

Replace `<container-id>` with the actual container ID or name, which you can find by running:

```bash
docker ps
```

### 4. Initialize the Database

After connecting to SQL Server, initialize the database by running the SQL scripts that set up the schema, functions, stored procedures, and sample data.

Run the script to create the schema, tables, and populate them with sample data:

```bash
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'University_P@ssw0rd' -C -i /usr/src/app/sql/10-tests.sql
```

Ensure that the path to your SQL scripts is correct.

## Queries and Testing

You can now begin querying the system and testing the functionalities. Here are some common queries and how to test the system:

### 1. List All Students

To see a list of all students:

```sql
SELECT * FROM Student;
```

### 2. List All Courses

To see a list of all courses:

```sql
SELECT * FROM Course;
```

### 3. List All Enrollments

To see a list of all enrollments:

```sql
SELECT * FROM Enrollment;
```

### 4. Register a Student for a Course

Use the `RegisterStudent` stored procedure to register a student for a course:

```sql
DECLARE @Output NVARCHAR(255);
EXEC RegisterStudent 
    @StudentID = 10001,  -- Replace with the student's ID
    @OfferingID = 1,     -- Replace with the course offering ID
    @DiscountPercentage = 10.00,  -- Optional
    @Output = @Output OUTPUT;

SELECT @Output AS Result;
```

### 5. Apply a Discount to Enrollment

Use the `ApplyEnrollmentDiscount` stored procedure to apply a discount to an enrollment:

```sql
DECLARE @Output NVARCHAR(255);
EXEC ApplyEnrollmentDiscount 
    @EnrollmentID = 1,      -- Replace with the enrollment ID
    @DiscountPercentage = 15.00,  -- Discount percentage
    @DiscountReason = 'Scholarship',  -- Optional reason for discount
    @ModifiedBy = 'Admin',  -- Modified by
    @Output = @Output OUTPUT;

SELECT @Output AS Result;
```

### 6. Assign a Grade to a Student

Use the `AssignGrade` stored procedure to assign a grade to a student:

```sql
DECLARE @Output NVARCHAR(255);
EXEC AssignGrade 
    @EnrollmentID = 1,  -- Replace with the enrollment ID
    @Grade = 'A',       -- Grade to assign (e.g., A, B+, etc.)
    @AssignedBy = 'Prof. Smith',  -- Name of the person assigning the grade
    @Output = @Output OUTPUT;

SELECT @Output AS Result;
```

### 7. Drop a Course

Use the `DropCourse` stored procedure to drop a course for a student:

```sql
DECLARE @Output NVARCHAR(255);
EXEC DropCourse 
    @EnrollmentID = 1,    -- Replace with the enrollment ID
    @Reason = 'Personal reasons',  -- Reason for dropping the course
    @Output = @Output OUTPUT;

SELECT @Output AS Result;
```

### 8. Calculate a Student's GPA

To calculate a student's GPA, use the `CalculateGPA` function:

```sql
SELECT dbo.CalculateGPA(10001);  -- Replace with the student ID
```

### 9. Check Prerequisites for a Course

To check if a student meets the prerequisites for a course, use the `CheckPrerequisites` function:

```sql
SELECT dbo.CheckPrerequisites(10001, 1);  -- Replace with student ID and course ID
```

## Troubleshooting

* Ensure that Docker is running and the container is up. You can check the logs using:

  ```bash
  docker logs <container-id>
  ```

* If you encounter connection issues with SQL Server, verify the connection settings (`-U sa -P 'University_P@ssw0rd'`) are correct.

* If SQL scripts are not running as expected, check for errors in the SQL Server logs.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---



