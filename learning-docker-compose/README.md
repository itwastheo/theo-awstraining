# Docker-Compose Getting Started Tutorial

- Here's a simple docker-compose.yml file that defines multiple services running different images. This setup includes a web server, a database, and a Redis cache:

In this docker-compose.yml:

We define three services: web, db, and redis.
- web: Uses the official Nginx image with the Alpine Linux distribution. It maps port 80 on the host to port 80 on the container.
- db: Uses the official MySQL 5.7 image. It sets environment variables for the MySQL root password, database name, username, and password.
- redis: Uses the official Redis image with the Alpine Linux distribution. It maps port 6379 on the host to port 6379 on the container.

To use this docker-compose.yml:

-   SSH into your EC2 instance.
-   Ensure Docker and Docker Compose are installed. If not, install them.
-   Create a directory for your project and navigate into it.
-   Create a file named docker-compose.yml and paste the above contents into it.
-   Run ``docker-compose up -d`` to start all the services in detached mode.

You should now have Nginx running on port 80, MySQL running with the provided credentials, and Redis running on port 6379 on your EC2 instance.

This setup provides a more comprehensive example for students to learn Docker Compose, including multiple services, image versions, environment variables, and port mappings. It demonstrates how to define and run a multi-container application stack with Docker Compose, which is a fundamental skill for deploying and managing applications in a containerized environment.
