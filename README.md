# Multi Tier Web Application Stack Setup Locally
 # Vprofile-Project1:
 
 ![](https://github.com/Adutoby/vprofile-project/blob/master/images/Frontpage.png)

# Prerequisite

To complete this project you should have your lab set-up with the appropriate tools.

   - Git Bash or any Code editor of choice
   - Oracle VirtualBox
   - Install Vagrant, and Vagrant Plugins.

# Firstly We Set-up our VMs

Clone the project repository to your local environment (using gitbash)

`git clone git@github.com:Adutoby/vprofile-project.git`

cd to the directory that has the Vagrantfile and run below command to start the VM via vagrant.

`Vagrant up`

![](https://github.com/Adutoby/vprofile-project/blob/master/images/vagrant-up1.png))

You might need to install vagrant plugins host-manger , run below command if you encounter errors while your VMs are coming up and run the Vagrant up command again

```vagrant plugin install vagrant-hostmanager```

 ```vagrant up```

*It is important to note that bringing up the VMs will take sometime depending on your internet speed. If setup process stops, run vagrant up command again until all 5 VMs are up and running.*

*INFO:* *All the vm’s hostname and /etc/hosts file entries will be automatically updated*

Check your Oracle Virtual-box Manager UI to see the VM’s setup and state running.

![](https://github.com/Adutoby/vprofile-project/blob/master/images/VMs-setup-complete.png)

With all the VM’s now setup, lets validate via ssh into the VM’s starting with the web server named web01. Run command..

`vagrant ssh web01`

![](https://github.com/Adutoby/vprofile-project/blob/master/images/web01-validation.png)

We are now inside the web server. Next, let us Check the host to validate all were automatically updated by running the cat command to view the content in in the /etc/hosts file

`cat /etc/hosts`

![](https://github.com/Adutoby/vprofile-project/blob/master/images/hostname-validation.png)

Great, now ping the app server to confirm connectivity and communication

`ping app01`

![](https://github.com/Adutoby/vprofile-project/blob/master/images/ping%20app01.png)

Connectivity was successful, logout of the web01 server and connect to the app01 server and check connectivity to the database VM db01, the memcache VM mc01 and the rabbitMQ VM respectively rmq01 since the application server will be communication directly with all 3 servers (VMs)

  `logout`

  `vagrant ssh app01`
  
  ![](https://github.com/Adutoby/vprofile-project/blob/master/images/db01%20ping.png)

app01 connects to db01 successfully i.e we have connectivity between the application server and the database server

![](https://github.com/Adutoby/vprofile-project/blob/master/images/mc01%20ping.png)

same for app server and Memcache server mc01 and finally checking connectivity between app01 and queuing agent RabbitMQ server rmq01 was also successful.

![](https://github.com/Adutoby/vprofile-project/blob/master/images/rmq01%20pingpng.png)

# Provisioning the VMs

The next stage will be to provision the servers manually and there are 6 different services that I will be provisioning in project architecture.

# Services
1. Nginx: Web Service
2. Tomcat: Application Server
3. RabbitMQ; Broker/Queuing Agent
4. Memcache; DB Caching
5. ElasticSearch; Indexing/Search service
6. MySQL; SQL Database

# Project Architecture

![](https://github.com/Adutoby/vprofile-project/blob/master/images/project%20achitecture.png)

The Setup for the service will be done in below order staring from setting up the Database service down to the Web service accordingly.
1. MySQL (Database SVC)
2. Memcache (DB Caching SVC)
3. RabbitMQ (Broker/Queue SVC)
4. Tomcat (Application SVC)
5. Nginx (Web SVC)

# Provisioning Database SVC — MySQL setup

  ssh into the db01

   `vagrant ssh db01`
  
  
Switch to root user and update all packages to latest patches when logged into the VM. Also set repository by installing EPEL Extra Packages for Enterprise Linux)

   `  sudo -i
    yum update -y
    yum install epel-release -y`


Set up db password using DATABASE_PASS environment variable and add it to /etc/profile file by running;

  `DATABASE_PASS='admin123'`

To save the variable permanently, add the variable to/etc/profile file and update it using a text editor of choice. I used vim so i install vim using yum install vim command first and then below scripts

  `vim /etc/profile
  source /etc/profile
  `

Next is to install Maria DB and git Package

  `yum install git mariadb-server -y`

Once Mariadb is installed, start and enable mariadb service. Also ensure to check the status of mariadb service to make sure it’s active (running).

  `systemctl start mariadb
  systemctl enable mariadb
  systemctl status mariadb`
  
 ![](https://github.com/Adutoby/vprofile-project/blob/master/images/mariadb-status.png)

RUN mysql secure installation script.

  `mysql_secure_installation
`

For db root password, I used admin123

![](https://github.com/Adutoby/vprofile-project/blob/master/images/mariadbsetup.png)

Validate connectivity to db with command below: at the password prompt enter admin123 . If connection is succesful exit from DB.

`mysql -u root -p`
  
 `exit`

![](https://github.com/Adutoby/vprofile-project/blob/master/images/dbacces%20check.png)

I proceeded to clone source code to db VM, change directory to src/main/resources/ to get the `sql queries.

    git clone https://github.com/devopshydclub/vprofile-project.git
    cd vprofile-project/src/main/resources/

![](https://github.com/Adutoby/vprofile-project/blob/master/images/dbconfigaccountsetup.png)

Create a database account, Configure the db and initialize

    mysql -u root -p"$DATABASE_PASS" -e "create database accounts"
    mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on accounts.* TO 'admin'@'app01' identified by 'admin123' "
    cd ../../..
    mysql -u root -p"$DATABASE_PASS" accounts < src/main/resources/db_backup.sql
    mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"

![](https://github.com/Adutoby/vprofile-project/blob/master/images/dbconfigaccountsetup.png)

Login to the database and verify

![](https://github.com/Adutoby/vprofile-project/blob/master/images/dbsetupvalidationpng.png)

Restart Mariadb server and logout, db is provisioned and ready
   
    systemctl restart mariadb
    
    exit

# Provisioning (DB Caching SVC) Memcache setup

following the flow of service provisioning highlighted above we will log-in to memcached server, (mc01) and switch to root user with below commands

    `vagrant ssh mc01`
    `sudo -i`


Just as MySQL provisioning, update OS with latest patches and download epel repository.

    `yum update -y`
    `yum install epel-release -y`
    `

Install memcached package.

    yum install memcached -y

Start/enable the memcached service and check the status of service.

    systemctl start memcached
    systemctl enable memcached
    systemctl status memcached
    
![](https://github.com/Adutoby/vprofile-project/blob/master/images/memcachesetup.png)

To enable memcached to listen on TCP port 11211 and UDP port 11111 run below command.

    memcached -p 11211 -U 11111 -u memcached -d

To Validate if the port is running, run command

    ss -tunlp | grep 11211

![](https://github.com/Adutoby/vprofile-project/blob/master/images/TCP-UDPport%20validation.png)

The Caching server is provisioned and ready, exit from server and continue to the next flow setup.

# Provisioning RabbitMQ

RabbitMQ is used as the queuing agent in the stack for a application. To begin the setup we login into Rabbit MQ server (rmq01) and switch to root user.

    vagrant ssh rmq01
    
    sudo -i

Updating OS with latest patches and install epel repository.

    yum update -y
    yum install epel-release -y
    

To install RabbitMQ, there are dependencies that should be installed first such a wget and erlang-solutions. Run below command to set those up.

    yum install wget -y
    cd /tmp/
    wget http://packages.erlang-solutions.com/erlang-solutions-2.0-1.noarch.rpm
    sudo rpm -Uvh erlang-solutions-2.0-1.noarch.rpm
    sudo yum -y install erlang socat

Next Install RabbitMQ server with command below

    curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash
    sudo yum install rabbitmq-server -y

Now start/enable the RabbitMQ service and check the status of service.

    systemctl start rabbitmq-server
    systemctl enable rabbitmq-server
    systemctl status rabbitmq-server
    
![](https://github.com/Adutoby/vprofile-project/blob/master/images/rmq01validation.png)

Set up a config change to Create a test user with password test, Create user_tag for the test user as administrator .

- Restart rabbitmq service after config change completion
    
    cd
    echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config
    rabbitmqctl add_user test test
    rabbitmqctl set_user_tags test administrator
    systemctl restart rabbitmq-server

- Validate service is active/running after restart

    systemctl status rabbitmq-server
 
 ![](https://github.com/Adutoby/vprofile-project/blob/master/images/rmq01validation.png)

Great!, exit rmq01 server to the next service.

# Tomcat Setup (Application SVC)

With vagrant, log into app01 server , and switch to root user.

  vagrant ssh app01
  sudo -i

As per best practice, Update OS with latest patches and download epel repository.

 yum update -y
 yum install epel-release -y
Install dependencies for Tomcat server. (git, wget, maven, java-1.8.0-openjdk)

    yum install java-1.8.0-openjdk -y
    yum install git maven wget -y

(change directory) cd to /tmp/ directory, and download Tomcat.

    cd /tmp
    wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.37/bin/apache-tomcat-8.5.37.tar.
    tar xzvf apache-tomcat-8.5.37.tar.gz
  

Add tomcat user and copy data to tomcat home directory.

Check the new user tomcat with id tomcat command.

    useradd --home-dir /usr/local/tomcat8 --shell /sbin/nologin tomcat

Copy your data to /usr/local/tomcat8 directory which is the home-directory for tomcat user.

    cp -r /tmp/apache-tomcat-8.5.37/* /usr/local/tomcat8/
   

Observe that root user has ownership of all files under /usr/local/tomcat8/ directory, change it to tomcat user.

    ls -l /usr/local/tomcat8/
    chown -R tomcat.tomcat /usr/local/tomcat8
    ls -l /usr/local/tomcat8/
   

- Setup systemd for tomcat

Create a file with below content. once created, Use systemctl start tomcat to start tomcat and systemctl stop tomcat to stop tomcat service.

    [Unit] 
    Description=Tomcat 
    After=network.target
    [Service]
    User=tomcat
    WorkingDirectory=/usr/local/tomcat8 
    Environment=JRE_HOME=/usr/lib/jvm/jre 
    Environment=JAVA_HOME=/usr/lib/jvm/jre 
    Environment=CATALINA_HOME=/usr/local/tomcat8 
    Environment=CATALINE_BASE=/usr/local/tomcat8 
    ExecStart=/usr/local/tomcat8/bin/catalina.sh run 
    ExecStop=/usr/local/tomcat8/bin/shutdown.sh 
    SyslogIdentifier=tomcat-%i
    [Install] 
    WantedBy=multi-user.target
    
![](https://github.com/Adutoby/vprofile-project/blob/master/images/script%20systemctl.png)
    
Any changes made to file under /etc/systemd/system/ directory, we need to run below command to be effective and Enable tomcat service.

The service name tomcat has to be same as given # `/etc/systemd/system/tomcat.service `.

  `systemctl daemon-reload`

  `systemctl enable tomcat`
  
  `systemctl start tomcat`
  
  `systemctl status tomcat`
  
![](https://github.com/Adutoby/vprofile-project/blob/master/images/tomcatserverstatus.png)

# Code Build & Deploy to Tomcat(app01) Server

Clone the source code into the /tmp directory, then cd into the vproject-project directory.

    git clone https://github.com/devopshydclub/vprofile-project.git
    cd vprofile-project/

To build the artifact with maven, we need to Update the configuration file that connect the backen services i.e, db, memcaches and the queuing agent rabbitMQ service.

This is done by editing the application.properties file in the */src/main/resources/application.properties* file using a text editor of your choice. I sued vim.

`vim src/main/resources/application.properties
`

In application.properties file:

Ensure the settings are correct. Check DB configuration: we named the db server `db01` , and we have `admin` user with password `admin123` setup as credentials.

For memcached service, hostname is mc01 and we validated it is listening on tcp port 11211.

For rabbitMQ, hostname is rmq01 and we have created user `test` with pwd `test`.

    #JDBC Configutation for Database Connection
    jdbc.driverClassName=com.mysql.jdbc.Driver
    jdbc.url=jdbc:mysql://db01:3306/accounts?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull
    jdbc.username=admin
    jdbc.password=admin123

    #Memcached Configuration For Active and StandBy Host
    #For Active Host
    memcached.active.host=mc01
    memcached.active.port=11211
    #For StandBy Host
    memcached.standBy.host=127.0.0.2
    memcached.standBy.port=11211

    #RabbitMq Configuration
    rabbitmq.address=rmq01
    rabbitmq.port=5672
    rabbitmq.username=test
    rabbitmq.password=test

    #Elasticesearch Configuration
    elasticsearch.host =192.168.1.85
    elasticsearch.port =9300
    elasticsearch.cluster=vprofile
    elasticsearch.node=vprofilenode

Next we build our code with maven using mvn install command to creat our artifact.Run below command inside the repository (vprofile-project). An Artifact will be created `/tmp/vprofile-project/target/vprofile-v2.war`

![](https://github.com/Adutoby/vprofile-project/blob/master/images/mvnbuild.png)

![](https://github.com/Adutoby/vprofile-project/blob/master/images/mvnbuildseccess.png)

    cd target/
    ls

cd to target and list to see the artifact, remove the default app from the Tomcat server and deploy the newly built artifact vprofile-v2.var to the Tomcat server

Ensure to stop the server first before removing the default from the /usr/local/tomcat8/webapps/ROOT directory. Give about 120seconds allowing the server to stop properly . use these command

    systemctl stop tomcat
    systemctl status tomcat
    rm -rf /usr/local/tomcat8/webapps/ROOT

![](https://github.com/Adutoby/vprofile-project/blob/master/images/stptomcatpng.png)

With our artifact is the vprofile-project/target directory, copy the artifact to `/usr/local/tomcat8/webapps/ directory as ROOT.war` then start tomcat server. Once started, it will extract our artifact `ROOT.war` under `ROOT` directory.


    cd ..
    cp target/vprofile-v2.war /usr/local/tomcat8/webapps/ROOT.war
    systemctl start tomcat
    ls /usr/local/tomcat8/webapps/


Give the application sometime to come up say around 200secs, whilw this happens we can proceed to set us the nginx server.

# Setup Nginx SVC

We used Ubuntu for the Nginx server, while all other servers are CentOs . As usually as per best practice, update OS with latest patches run below command this time using apt package manager:

    sudo apt update && sudo apt upgrade

Switch to root user and install nginx.

    sudo -i
    apt install nginx -y

Next we create an nginx configuration file under directory `/etc/nginx/sites-available/`. 
This allows nginx to act as a load balancer with below content:

    vim /etc/nginx/sites-available/vproapp


      upstream vproapp {
      server app01:8080;
      }
      server {
      listen 80;
      location / {
      proxy_pass http://vproapp;
      }
      }

Remove default nginx config file:

    rm -rf /etc/nginx/sites-enabled/default

Create a symbolic link for our configuration file using default config location detailed below to enable our site and restart nginx server.

    ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp
    systemctl restart nginx

# Validate Application(stacks) from Browser

From inside of the web01 server, run ifconfig command to display its IP address. IP address of our web01 : `192.168.56.11`

![](https://github.com/Adutoby/vprofile-project/blob/master/images/ifconfignginx.png)

Now open a browser and enter the web app IP address to validate nginx is running `192.168.56.11`. 
you should see the login page

![](https://github.com/Adutoby/vprofile-project/blob/master/images/nginx%20page.png)

Next validate db connection using credentials `admin_vp` for both username and password. 
connect successful!! show that app is running from Tomcat server through the web server.

![](https://github.com/Adutoby/vprofile-project/blob/master/images/dbvalidationpage.png)

To validate RabbitMQ connection, click RabbitMQ on page and it should return below on display.

![](https://github.com/Adutoby/vprofile-project/blob/master/images/rabbitmqvalidate.png)

To validate Memcache connection, click on All user button on the front page to load all users and them click on any user

![](https://github.com/Adutoby/vprofile-project/blob/master/images/uservalidation.png)

Validate data is coming from Database when user first time requests it.

![](https://github.com/Adutoby/vprofile-project/blob/master/images/memcachevalidate.png)

Validate data is coming from Memcached when user second time requests it.

![](https://github.com/Adutoby/vprofile-project/blob/master/images/cachevalidate2.png)

Great Job making it this far, we have successfully setup tools for our stack , clone the source code , 
via vagrant we brought up our VM’s and validated them , we successfully setup all our services Mysql, 
Memcached, Rabbit MQ, Tomcat Nginx and built and deployed them and finally we have validated to see all work perfectly.

The exercise might seems time consuming but it helps to understand granularity of how to provision the aforementioned 
and their interaction, communication flow and they are interconnected. My next project will show how to automate this 
entire process using script

# Cleanup

Navigate to the project directory in manual provisioning directory where the vagrant file is contained, run the command `Vagrant destroy` 
to bring down all virtual machines. The exercise might seems time consuming but it helps to understand granularity of how to provision 
the aforementioned and their interaction, communication flow and they are interconnected. My next project will show how to automate 
this entire process using script

    vagrant destroy

![](https://github.com/Adutoby/vprofile-project/blob/master/images/Destroy.png)
