**Using Docker Compose to install SonarQube is a streamlined way to set up and manage your SonarQube environment. Below are the steps to do this:**

**Hardware requirements**
A small-scale (individual or small team) instance of the SonarQube server requires at least 2GB of RAM to run efficiently and 1GB of free RAM for the OS. If you are installing an instance for a large team or an enterprise, please consider the additional recommendations below.

**Install Docker and Docker Compose:**
Ensure you have Docker and Docker Compose installed on your machine. You can download and install them from Docker's official website.

**Create a Docker Compose file:**
Create a docker-compose.yml file in your working directory. This file will define the services for SonarQube and its database, PostgreSQL.

In the `docker-compose.yml' configuration:

- The sonarqube service uses the latest SonarQube image and is configured to depend on the db service.
- The db service uses the latest PostgreSQL image.
- Environment variables are set for the SonarQube database connection.
- Volumes are used to persist SonarQube and PostgreSQL data.

**Run Docker Compose:**
Open a terminal, navigate to the directory where your docker-compose.yml file is located, and run the following command to start the services:

`docker-compose up -d`
The -d flag runs the services in detached mode, meaning they will run in the background.

**Access SonarQube:**
Once the services are up and running, you can access SonarQube by opening a web browser and navigating to http://localhost:9000. The default login credentials are:

`Username`: `admin`
`Password`: `admin`

**Verify Setup:**
You can verify that both SonarQube and PostgreSQL containers are running using the following command:

`docker-compose ps`
This will display the status of your containers.

By following these steps, you should have a working SonarQube instance running in Docker containers managed by Docker Compose.

