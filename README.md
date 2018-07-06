tp3/docker
============================

TYPO3 docker testing image - This image is part of an automated testing enviroment.
Webservice can be linked to MySQL. More about the automated testing 
https://bitbucket.org/web-tp3/tp3_installer


Usage (standalone)
------------------

This image needs an external MySQL server or linked MySQL container. To create a MySQL container:

    docker run -d -e MYSQL_ROOT_PASSWORD="**ChangeMe**" --name db -p 3306:3306 webtp3/tp3sql

To run TYPO3 by linking to the database created above:

    docker run -d --rm -it -v $PWD:/build --link db:db -e DB_PASS="**ChangeMe**" -p 80:80 webtp3/docker:16.4-stable

Usage (combined)
------------------
ia docker stack deploy or docker-compose

    docker-compose -f docker-compose.yml up

Now, you can use your web browser to access TYPO3 from the the follow address:

    http://localhost/typo3

User is "tp3min" and password is "Init1111".

more about the base images an be foun on the docker hub:

Web Server
https://hub.docker.com/_/ubuntu/

Database Server
https://hub.docker.com/_/mysql/
 
