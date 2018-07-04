tp3/docker
============================

Out-of-the-box TYPO3 docker image which can be linked to MySQL.


Usage (standalone)
------------------

This image needs an external MySQL server or linked MySQL container. To create a MySQL container:

    docker run -d -e MYSQL_PASS="<your_password>" --name db -p 3306:3306 tutum/mysql:5.5

To run TYPO3 by linking to the database created above:

    docker run -d --link db:db -e DB_PASS="<your_password>" -p 80:80 tp3de/typo3

Now, you can use your web browser to access TYPO3 from the the follow address:

    http://localhost/typo3

User is "admin" and password is "password".

Usage (as a base image)
-----------------------

If you want to use it as a base image to create your customized version of TYPO3, you can do so by creating a `Dockerfile` similar to the following:

    FROM tp3de/typo3:latest

    # Add an initial data which will be automatically loaded when creating the database for the first time
    ADD initial_db.sql /initial_db.sql

    # Add a custom composer.json
    ADD composer.json /app/composer.json