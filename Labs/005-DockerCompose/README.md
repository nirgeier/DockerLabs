
<a href="https://stackoverflow.com/users/1755598"><img src="https://stackexchange.com/users/flair/1951642.png" width="208" height="58" alt="profile for CodeWizard on Stack Exchange, a network of free, community-driven Q&amp;A sites" title="profile for CodeWizard on Stack Exchange, a network of free, community-driven Q&amp;A sites"></a>

![Visitor Badge](https://visitor-badge.laobi.icu/badge?page_id=nirgeier)
[![Linkedin Badge](https://img.shields.io/badge/-nirgeier-blue?style=plastic&logo=Linkedin&logoColor=white&link=https://www.linkedin.com/in/nirgeier/)](https://www.linkedin.com/in/nirgeier/)
[![Gmail Badge](https://img.shields.io/badge/-nirgeier@gmail.com-fcc624?style=plastic&logo=Gmail&logoColor=red&link=mailto:nirgeier@gmail.com)](mailto:nirgeier@gmail.com)
[![Outlook Badge](https://img.shields.io/badge/-nirg@codewizard.co.il-fcc624?style=plastic&logo=microsoftoutlook&logoColor=blue&link=mailto:nirg@codewizard.co.il)](mailto:nirg@codewizard.co.il)

---

![](../../resources/docker-logos.png)

---
![](../../resources/hands-on.png)

# Lab 005: Docker Compose - WordPress & MariaDB <!-- omit in toc -->



This lab demonstrates how to use Docker Compose to orchestrate a simple multi-container application: WordPress with a MariaDB database backend.

## Overview

- The provided `docker-compose.yaml` file defines two main services:

  - **db**: Runs a MariaDB database (can be switched to MySQL if desired).
  - **wordpress**: Runs the latest WordPress application, connected to the database.

- A named volume `db_data` is used to persist database data.

## docker-compose.yaml Breakdown

- **db service**
  - Uses the `mariadb:10.6.4-focal` image (or optionally MySQL).
  - Sets up environment variables for root password, database, user, and password.
  - Persists data in a Docker volume.
  - Exposes ports 3306 and 33060 (internal only).

- **wordpress service**
  - Uses the latest WordPress image.
  - Maps port 80 on the host to port 80 in the container.
  - Configures environment variables to connect to the database.

- **volumes**
  - `db_data`: Persists MariaDB data between container restarts.

## Bonus Demo

- I prepared a demo of this lab, which you can view on KillerCoda: [Portainder Demo](https://killercoda.com/codewizard/scenario/Portainer).
- The demo is showcases for setting and running multuple containers using Docker Compose
- The demo is available on [KillerCoda](https://killercoda.com/codewizard/scenario/Portainer).

---


## How to Run the Lab

1. **Navigate to the lab directory:**
   ```sh
   cd Labs/005-DockerCompose
   ```

2. **Start the services:**
   ```sh
   docker compose up -d
   ```
   - This will pull the required images (if not already present) and start both the database and WordPress containers in detached mode.

3. **Access WordPress:**
   - Open your browser and go to [http://localhost](http://localhost)
   - Complete the WordPress setup wizard.

4. **Stop the services:**
   ```sh
   docker compose down
   ```
   This will stop and remove the containers, but the database data will persist in the `db_data` volume.

## Notes
- To use MySQL instead of MariaDB, uncomment the relevant line in the compose file and comment out the MariaDB image line.
- The database credentials are set for demonstration purposes. For production, use secure passwords.
- The `db` service is only accessible to the `wordpress` service (not exposed to the host).

## Troubleshooting
- If you encounter port conflicts, ensure nothing else is running on port 80.
- To view logs for a service:
  ```sh
  docker compose logs wordpress
  docker compose logs db
  ```

---

This lab is part of the DockerLabs series. See other labs for more Docker scenarios and hands-on exercises.
