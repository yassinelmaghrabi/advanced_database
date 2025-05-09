FROM mcr.microsoft.com/mssql/server:2022-latest

USER root

# Create directory for database files
RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

# Copy SQL scripts
COPY ./sql/ /usr/src/app/sql/

# Install scripts will run at container startup
COPY ./scripts/init.sh /usr/src/app/init.sh
RUN chmod +x /usr/src/app/init.sh

USER mssql

# Setup the entrypoint
CMD /bin/bash ./init.sh
