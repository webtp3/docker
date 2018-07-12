tp3/docker
============================

TYPO3 docker testing image - This image is part of an automated testing enviroment.
Webservice can be linked to MySQL. More about the automated testing 
https://bitbucket.org/web-tp3/tp3_installer


Usage (standalone)
------------------

This image needs an external MySQL server or linked MySQL container. To create a MySQL container:

    docker run -d -e MYSQL_ROOT_PASSWORD="my-secret-pw" --name db -p 3306:3306 webtp3/tp3sql

To run TYPO3 by linking to the database created above:

    docker run -d --rm -it -v $PWD:/build --link db:db -e DB_PASS="my-secret-pw" -p 80:80 --name typo3 webtp3/docker:16.4-stable
    
to have a bash simply add bash to the end of the command (as you can run any command in the docker image)
"docker run -d --rm -it -v $PWD:/build --link db:db -e DB_PASS="my-secret-pw" -p 80:80 --name typo3 webtp3/docker:8-stable bash"

Following branches are available:
8-stable (with typo3 installed)
16.4-stable (just apache and php 7.1 - waiting for install in /var/www/html)
18.4-stable (just apache and php 7.2 - waiting for install in /var/www/html)
 
    docker cp typo3 /from/ /to/        (Copy files/folders between a container and the local filesystem)

 
 
Usage (combined)
------------------
ia docker stack deploy or docker-compose

    docker-compose -f docker-compose.yml up

Now, you can use your web browser to access TYPO3 from the the follow address:

    http://localhost/typo3
    User is "tp3min" and password is "Init1111".

    
The mysql Adminer 

    http://localhost:8080

Mysql Server can also be reached from outside on port 3306

SSH Server also for Rsync and other stuff
to use ssh server there is a user typo3user that needs a password (docker exec...)
graphicsmagick, imagemagick, letscrypt, openssl, php-xdebug and I think all what you need.

Documentation 
------------------

 more about the base images an be found on the docker hub:

https://hub.docker.com/r/webtp3/docker 

The System runs with a php fastcgi wrapper. So you can easyly swap php Versions to tests on several ons.

Web Server
https://hub.docker.com/_/ubuntu/

Database Server
https://hub.docker.com/_/mysql/
 
