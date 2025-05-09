#!/bin/bash

# Start SQL Server
/opt/mssql/bin/sqlservr &

# Wait for SQL Server to start up
sleep 30s

# Create database and run scripts
echo "Initializing University Enrollment Database..."

# Run all SQL scripts in order
for script in /usr/src/app/sql/*.sql; do
  echo "Running $script..."
  /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P $SA_PASSWORD -C -i "$script"
done

echo "Database initialization complete!"

# Keep container running
tail -f /dev/null
