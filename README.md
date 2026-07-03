# College Event Site — TechFest 2026 (DevOps Assignment 2, Use Case 2)

A College Symposium website (Home, Schedule, Speakers, Register,
Announcements) deployed with a full DevOps workflow:

**Git → Jenkins (CI/CD) → Maven → Docker → Kubernetes → Nagios + Graphite + Grafana (monitoring)**

There are **two versions** of the app in this repo — pick ONE for your submission:

| | `app/` (plain static site) | `backend/` (Maven / Spring Boot) ⭐ recommended |
|---|---|---|
| Language | HTML/CSS/JS only | Java 25 + Spring Boot 4.1, built with **Maven** |
| Serves the website via | Nginx | Spring Boot (serves the same HTML/CSS/JS from `src/main/resources/static`) |
| Announcements | Hardcoded in HTML | Real REST API: `GET /api/announcements` |
| Registration form | Client-side only (fake success message) | Real REST API: `POST /api/registrations`, validated with Bean Validation |
| Health check | `/healthz` via Nginx | `/healthz` (custom) + `/actuator/health` (Spring Boot Actuator) |
| Port | 8080 (Docker) / 30080 (K8s NodePort) | 8081 app + 9090 actuator (Docker) / 30081 + 30090 (K8s NodePort) |
| Jenkins build stages | Docker build only | **Maven clean → compile → test → package**, then Docker build |

Since your assignment checklist explicitly asks for a **Maven build**, use the
**`backend/`** folder — the rest of this README focuses on that.
(The static `app/` version still works if you ever want the simpler option.)

---

## 1. Project Structure

```
college-event-site/
├── app/                          # (Alternative) plain static site + Nginx
│   └── ... (not covered below — see the table above)
│
├── backend/                      # ⭐ Maven / Spring Boot version — use this one
│   ├── pom.xml                   # Maven build file
│   ├── mvnw / mvnw.cmd           # (optional — add Maven wrapper, see Step 2)
│   ├── src/main/java/com/college/techfest/
│   │   ├── TechfestApplication.java
│   │   ├── controller/AnnouncementController.java
│   │   ├── controller/RegistrationController.java
│   │   ├── controller/HealthController.java
│   │   ├── service/AnnouncementService.java
│   │   ├── service/RegistrationService.java
│   │   └── model/Announcement.java, Registration.java
│   ├── src/main/resources/
│   │   ├── application.properties
│   │   └── static/                # index.html, schedule.html, speakers.html,
│   │                               # register.html, announcements.html, css/, js/
│   ├── src/test/java/...          # JUnit test (Spring context load test)
│   ├── Dockerfile                 # Builds a JDK image around the Maven jar
│   ├── Jenkinsfile                # CI/CD pipeline WITH Maven build stages
│   └── k8s/
│       ├── deployment.yaml
│       └── service.yaml           # NodePort 30081 (app), 30090 (actuator)
│
└── monitoring/
    ├── docker-compose-monitoring.yml   # Graphite + Grafana
    ├── docker-compose-nagios.yml       # Nagios Core
    ├── nagios/objects/college-event-site.cfg
    ├── scripts/push_metrics_to_graphite.sh
    └── grafana/college-event-dashboard.json
```

---

## 2. Prerequisites (install once)

- Git
- **Java 25 (JDK)** and **Maven** — check with `java -version` and `mvn -version`.
  If Maven isn't installed:
  - Windows: download from https://maven.apache.org/download.cgi and add `bin/` to PATH
  - macOS: `brew install maven`
  - Linux: `sudo apt install maven`
- Docker Desktop (includes Docker + can enable Kubernetes)
- kubectl (comes with Docker Desktop's Kubernetes, or install separately)
- Jenkins (local install, or run via Docker — see step 5)
- A GitHub account

---

## 3. Step 1 — Push the project to GitHub

```bash
cd college-event-site
git init
git add .
git commit -m "Initial commit - College Event Site DevOps project (Maven backend)"
git branch -M main
git remote add origin https://github.com/<your-username>/college-event-site.git
git push -u origin main
```

> Use this GitHub link as your "GitHub Repository Link" in the report.

---

## 4. Step 2 — Build with Maven and run locally (sanity check)

```bash
cd backend
mvn clean package -DskipTests
```

This downloads dependencies, compiles the Java code, and produces
`target/techfest-0.0.1-SNAPSHOT.jar`. Take a terminal screenshot of this
succeeding — useful evidence of the "Maven build completed successfully"
checklist item.

Run it directly with Java first, just to confirm it works before touching Docker:
```bash
java -jar target/techfest-0.0.1-SNAPSHOT.jar
```
Open **http://localhost:8081** — you should see the Home page. Also try:
- **http://localhost:8081/api/announcements** — should return JSON
- **http://localhost:9090/actuator/health** — should return `{"status":"UP"}`

Stop it with `Ctrl+C`.

---

## 5. Step 3 — Build the Docker image and test it

```bash
docker build -t techfest-backend:v1 .
docker run -d -p 8081:8081 -p 9090:9090 --name techfest-backend techfest-backend:v1
```

Open **http://localhost:8081** in your browser. Take a screenshot for the
report (this is your "Docker Build and Running Container Screenshot").

Stop the test container before moving to Kubernetes:
```bash
docker stop techfest-backend && docker rm techfest-backend
```

---

## 6. Step 4 — Enable Kubernetes and deploy

1. In Docker Desktop → Settings → Kubernetes → check **Enable Kubernetes** → Apply & Restart.
2. Verify:
   ```bash
   kubectl get nodes
   ```
3. Make sure the image is built (Docker Desktop shares its local image cache
   with Kubernetes automatically):
   ```bash
   docker build -t techfest-backend:v1 .
   ```
4. Deploy (still inside `backend/`):
   ```bash
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml
   ```
5. Check status:
   ```bash
   kubectl get pods
   kubectl get deployments
   kubectl get svc
   ```
6. Open the site: **http://localhost:30081**

Take screenshots of `kubectl get pods` / `kubectl get svc` (Running state) and
the browser showing the site — these satisfy the "Kubernetes Deployment
Screenshots" and "Application Output Screenshots" requirements.

---

## 7. Step 5 — Set up Jenkins CI/CD

### Option A: Jenkins installed locally
1. Install Jenkins, open `http://localhost:8080` (Jenkins' own port — this is separate from the app's port 8081, so no clash).
2. Install the recommended plugins + **Docker Pipeline**, **Kubernetes CLI**,
   **Maven Integration**, and **Eclipse Temurin installer** (or point it at
   your system JDK) plugins.
3. Manage Jenkins → Tools → add a JDK named `JDK25` and a Maven install named
   `Maven-3.9` (these names are referenced in `backend/Jenkinsfile`'s `tools {}`
   block — rename either to match what you configure).
4. Create a New Item → Pipeline → name it `college-event-site-pipeline`.
5. Under Pipeline → Definition → "Pipeline script from SCM" → SCM: Git →
   paste your GitHub repo URL → **Script Path: `backend/Jenkinsfile`**
   (note the `backend/` prefix, since the Jenkinsfile now lives inside that folder).
6. Click **Build Now**.

### Option B: Jenkins in Docker (quick local setup)
```bash
docker run -d --name jenkins -p 8090:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
```
Then open `http://localhost:8090`, unlock with the initial admin password:
```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
This base image doesn't include Java/Maven for building — either install the
Maven Integration plugin and let Jenkins auto-install a JDK 25/Maven under
Manage Jenkins → Tools, or use a Jenkins image that bundles a recent JDK
(check Docker Hub for the latest `jenkins/jenkins:lts-jdkXX` tag available)
and add Maven via the plugin's auto-installer.
Then follow the same pipeline setup as Option A.

**For the report:** take screenshots of the Jenkins Dashboard, the Job
Configuration screen, the Console Output of a successful build, and the green
"Successful Build" status — this covers the "Jenkins Build URL / Screenshots"
requirement.

---

## 8. Step 6 — Monitoring: Graphite + Grafana

1. Start Graphite and Grafana:
   ```bash
   cd monitoring
   docker compose -f docker-compose-monitoring.yml up -d
   ```
2. Confirm containers are running:
   ```bash
   docker ps
   ```
3. Start pushing system + website metrics into Graphite (run this from your
   terminal, on the Docker/Kubernetes host machine — needs `nc` and `curl`,
   both preinstalled on most Linux/macOS systems, or run inside WSL on Windows):
   ```bash
   cd scripts
   ./push_metrics_to_graphite.sh
   ```
   Leave this running in a terminal window while you take your screenshots.
4. Confirm metrics are arriving in Graphite: open
   **http://localhost:8080** → Graphite web UI (this is the Graphite container's port, unrelated to Jenkins/app ports) → in the metrics tree, expand
   `college_event_site → system` and `college_event_site → app`. Take a
   screenshot — this is your "Graphite Metrics Screenshot".
5. Set up Grafana:
   - Open **http://localhost:3000** → log in with `admin` / `admin` (you'll
     be asked to change the password).
   - Go to **Connections → Data sources → Add data source → Graphite**.
     Set URL to `http://graphite:80` (container-to-container name) → **Save & Test**.
   - Go to **Dashboards → New → Import**, and upload
     `monitoring/grafana/college-event-dashboard.json` (or paste its contents).
   - Select the Graphite data source you just created → **Import**.
6. You should now see panels for CPU, Memory, Disk, Network, HTTP
   Availability and Uptime. Take a screenshot — this is your "Grafana
   Dashboard Screenshot".

---

## 9. Step 7 — Monitoring: Nagios

1. Start Nagios:
   ```bash
   cd monitoring
   docker compose -f docker-compose-nagios.yml up -d
   ```
2. Open **http://localhost:8081/nagios** → log in with `nagiosadmin` / `nagios`.
3. Go to **Services** — you should see the host `college-event-host` with
   services `HTTP - Website Availability` and `PING`. They should turn
   **green (OK / UP)** once Nagios completes its first check cycle
   (may take 1–2 minutes).

   > If checks show as unreachable, edit
   > `monitoring/nagios/objects/college-event-site.cfg` and change the
   > `address` field from `127.0.0.1` to your machine's actual local IP
   > address (find it with `ipconfig` / `ifconfig`), since Nagios runs
   > inside its own container and needs to reach the NodePort 30081 on
   > your host machine. Restart the Nagios container after editing.

4. Take a screenshot of the Nagios "Service Status Details" page showing
   Host UP and Services OK — this is your "Nagios Monitoring Screenshot".

---

## 10. Step 8 — Stopping everything (cleanup)

```bash
kubectl delete -f k8s/service.yaml
kubectl delete -f k8s/deployment.yaml
cd monitoring
docker compose -f docker-compose-monitoring.yml down
docker compose -f docker-compose-nagios.yml down
```

---

## 11. Mapping to the Assignment Checklist

| Requirement | Where it's satisfied |
|---|---|
| Maven build | `backend/pom.xml`, `mvn clean package` (Step 2), Jenkinsfile Maven stages (Step 5) |
| Version control / collaboration | Git repository (Step 3) |
| Automated deployment on update | backend/Jenkinsfile pipeline (Step 5) |
| Docker-based hosting | Dockerfile, nginx (Step 4) |
| Kubernetes deployment | backend/k8s/deployment.yaml, backend/k8s/service.yaml (Step 4) |
| Website availability | http://localhost:30081 (NodePort Service) |
| Website availability monitoring | Nagios HTTP check (Step 8) |
| Server resource metrics collection | Graphite via push_metrics_to_graphite.sh (Step 6) |
| Monitoring dashboards | Grafana dashboard: CPU, Memory, Disk, Network, Uptime (Step 6) |

---

## 12. Notes / Customization Ideas (optional, for extra polish)

- Replace the placeholder speaker names/photos with real ones for your college's event.
- Add real logos/images to `app/images/` and reference them in the HTML.
- If you'd rather push the Docker image to Docker Hub, uncomment the
  "Push to Docker Hub" stage in the `Jenkinsfile` and add your Docker Hub
  credentials in Jenkins (Manage Jenkins → Credentials).
- If you prefer GitHub Actions instead of Jenkins, the same Docker build +
  `kubectl apply` commands can be wrapped in a `.github/workflows/deploy.yml`.
