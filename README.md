# Inception

The goal of the project is to create a docker network consisting of three docker containers (Nginx, WordPress, and MariaDB) to serve a WordPress website.

**Cloning this repository will not result in a working docker network, since the docker secret, and environment variable files are not included in the repository.**

## Introduction

By inputting the URL http://localhost:80 in the browser address bar, the user agent (browser) sends a request to port 80 of the localhost. If there is no web server listening to requests on this port, we encounter the error page "This site can't be reached". Now, if we run a server software which is always listening to requests on port 80 of the localhost and assign it to serve a `.html` file, it will respond to the request by sending that HTML file to the browser and browser can parse and render the file.

## Nginx

Instead of running the web server on the local machine, we can run a docker container in which a web server, e.g. Nginx, runs. The docker container is like a server hardware and the Nginx installed on it works as a server software.

By default, Nginx listens to requests on port 80, and when it receives a request, it tries to respond to the request according to two important directives in its configuration files<sup>1</sup>. The first one is `index` directive, which indicates the priority of the files that Nginx must serve. If the value for index, which can be a list of files, begins with index.html means that Nginx will go to `root` and searches for the file index.html. If the file exists in the root directory, Nginx will send it to the browser. Browser can parse the HTML files, and therefore it can render the file, and show the HTML page. If the index.html file does not exist, Nginx will search for the next file in the index directive and if it cannot find any of the files in the index directive list, it will send an error page to the browser. `root` is the other important directive in Nginx configuration file. It indicates the directory in which the files that Nginx must serve are located.

So, by running the Nginx docker container, we can get Nginx to serve HTML files for us. But as the request is being sent in the local machine, e.g. on port 80, and Nginx is listening to requests on port 80 of the container, we must use the docker port mapping. By mapping the port 80 of the local host to the port 80 of the Nginx container, docker transfers the requests which are sent to the port 80 of the localhost, to the port 80 of the container. So, Nginx server software receives a request on port 80, and sends the HTML file located in its root directory to our browser (local machine).

In order to use HTTPS protocol rather than HTTP, we can modify the configuration file, and get Nginx to listen to port 443 (port mapping must change to 443:443 as well). A TLS/SSL certificate is required, too. For the purpose of this project, a self-signed TLS/SSL certificate is enough. To get a self-signed certificate, we can install and use `openssl`.

<sub>1. Nginx has a main configuration file, nginx.conf, which contains some general configurations, and it also includes the files which are located in specific directories, and contain some other configurations. We can customize the configurations by modifying these files.</sub>

## Wordpress

A WordPress website consists of PHP files, and not HTML files. If the index directive in the Nginx configuration file has index.php as its value, and Nginx sends the PHP file to our browser, the browser cannot render it because it does not know PHP. So, a server software is needed to receive the PHP files from Nginx and to generate HTML files from them. This server is php-fpm.

## How to connect Wordpress and Nginx containers?

The WordPress container, besides the PHP web page files, the WordPress CLI, and the WordPress core, includes the php-fpm which is always listening to requests on a specific port, which is 9000 by default, and responds to the requests. So, we must specify in the Nginx configuration file that Nginx must send the PHP files to port 9000 of the WordPress container and sends us the result that it receives from php-fpm server, which is an HTML file<sup>2</sup>.

<sub>2. As we are using a docker network, docker has already handled the IP addresses of the containers and put them in the same network. Also, we do not need to use the IP address of the destination container. Instead, we can use `docker_container_name` or `docker_container_name.docker_network_name`, and docker will substitute it by the container's IP address.</sub>

## Mariadb

A WordPress website, besides a web server (Nginx), and php-fpm, needs a database where the website data can be stored, modified or retrieved from. So, we need the third container, which is MariaDB. In this container, we must install MariaDB server which is a software that starts running in the container and always listens to requests on a specific port, which is 3306 by default, and responds to them.

## How to connect Mariadb and Wordpress containers?

MariaDB must create a user and set a password for it for each client that needs to connect to MariaDB, and that client needs to use this data to establish the connection with MariaDB.

`CREATE USER 'username'@'docker_container_name.docker_network_name' IDENTIFIED BY 'password';` <br />
The above query creates a user called "username", and sets its password, and assigns it for the client WordPress.

`ALTER USER 'root'@'localhost' IDENTIFIED BY 'password';`<br />
The above query sets the password for "root" and permits root to connect to MariaDB server from the localhost.

Also, MariaDB must create a database for WordPress, and WordPress can connect to MariaDB using this user, password, database name, the IP address of the MariaDB server hardware, and the port on which MariaDB server software (mariadbd or mariadb daemon) is listening to requests (we can use `mariadb_docker_container_name.docker_network_name` instead of the IP address and the port number). So, we need to create a shell script file, and copy it to the MariaDB container, and execute it at the container run-time (entry point). This shell script file is responsible for running some queries to create the database user, its password, and WordPress database.

Also, we need a shell script file in the WordPress container to be executed at the run-time, and do the following jobs:

1. creating the wp-config.php file using the data created by MariaDB. Also, MariaDB hostname is required for creating this file. As mentioned previously, we can use the `mariadb_docker_container_name.docker_network_name` and docker will substitute it by the container's hostname or IP address<sup>3</sup>.
2. Creating an admin for the WordPress website
3. Creating a user for the WordPress website

<sub>3. Here we can explicitly mention that the requests which are going to be sent from WordPress container to MariaDB must be sent to which port `mariadb_docker_container_name.docker_network_name:port_number`. In case of using a different port number from the default one, which is 3306, e.g. 3307, only for testing purposes because the subject asks for port 3306, we must apply this change in the MariaDB configuration file explicitly by adding `port = 3307` </sub>

## How to use MariaDB CLI to write queries in the MariaDB container?

We can use the command `mariadb --host=host --user=user --password=password` to execute MariaDB queries. When running this command in the MariaDB container, `host` is localhost, and if we have previously set the "MariaDB root password" for localhost, we need to use `root` for the user and its password for the value of the option --password.

## How to use MariaDB CLI to write queries in the WordPress container?

As WordPress is a client that sends requests to MariaDB server, we need to install mariadb-client in the WordPress container. Then we can use the command `mariadb --host=host --user=user --password=password` to execute MariaDB queries. `host` is `mariadb_docker_container_name.docker_network_name`, `user` is MariaDB user which was previously created by MariaDB for accessing to MariaDB from WordPress container, and `password` is its password.

## Docker secrets and environment files

The sensitive data that must not be exposed can be stored in environment files or in docker secret files. Environment files are the files which contain some key-value pairs, with the syntax `key=value` and these key value pairs will be injected by docker into the environment variables of the container that we need them.
Docker secrets are the files that can store some sensitive data such as passwords and docker can copy these files in a specific directory `/run/secrets` in any container that needs them.

## More details

When a container starts running, it will continue running as far as its main process (PID 1) has not exited. Therefore, the services (server software) that we want to run in the containers (server hardware) must be running in the main process. So, if a service, e.g. Nginx, runs as a daemon (in background) it means it is running in a child process created by a fork which makes the main process to exit, and this makes the container to exit, too assuming its job is finished.

In a Dockerfile, if we use `CMD ["nginx", "-g", "daemon off;"]` after `ENTRYPOINT["/directory_in_container/./shell_script.sh"]`, the arguments of the CMD will be assumed as arguments of the ENTRYPOINT command, so we need to explicitly make the CMD command to run as a seperate command, and not as the arguments for the ENTRYPOINT command:

1. Only using `CMD ["/directory_in_container/./shell_script.sh"]`, and running the service,`exec nginx -g "daemon off;"`, at the end of the shell_script.sh file (the shell script file must be copied to the container)
2. Using both `ENTRYPOINT ["/directory_in_container/./shell_script.sh"]` and `CMD ["nginx", "-g", "daemon off;"]`, and running the CMD command at the end of the shell_script.sh file using `exec "$@"` ("@" includes all the CMD arguments, and passing it to the exec command results in the same command as mentioned in the previous approach.

The current process which is the main process, and is executing the script file will be replaced by the `exec` process. So, a new process will run the CMD command, but with the same PID as the previous process, which is PID 1)
