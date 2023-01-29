In this project, I manually created VMs with Vagrantfile for a 3-Tier Application Stack setup consiting MySQL/MariaDB , Memcached , RabbitMQ , Tomcat and Nginx use bash to manually configure Linux servers. In the Tomcat server, Maven was used to build and deploy the artifact.
# Set-up Steps:
  - Use vagrant to create VMs via oracle Virtual Box, manually Log into each machine and execute shell commands using Bash
  - Set-up the services.
  - Once the stacks are ready, verify as a user from the browser. 
  - Access the Nginx service which serves as a load balancer that forwards the request to the tomcat server, which will then forward that request to the message broker RabbitMQ, then to Memcached, and finally to the MySQL server.

# Prerequisites
  - JDK 1.8 or later
  - Maven 3 or later
  - MySQL 5.6 or later

# Technologies
  - Spring MVC
  - Spring Security
  - Spring Data JPA
  - Maven
  - JSP
  - MySQL

# Database
  We used Mysql DB MSQL DB Installation Steps for Linux ubuntu 14.04 Run bash scripts

  - $ sudo apt-get update to the server
  - $ sudo apt-get install mysql-server to install mysql-server

Then look for the file 
  - /src/main/resources/accountsdb -accountsdb.sql file is a mysql dump file. 
  - Import this dump to mysql db server -mysql -u <user_name> -p accounts < accountsdb.sql
