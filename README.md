# TechFest 2026 — College Event Site (DevOps Assignment 2, Use Case 2)

A College Symposium website (Home, Schedule, Speakers, Register,
Announcements) built as a single **Java 25 + Spring Boot 4.1 (Maven)**
application, deployed with a full DevOps workflow:

**Git → Jenkins (CI/CD, Maven build) → Docker → Kubernetes → Nagios + Graphite + Grafana (monitoring)**

This project is structured exactly like your `taskmanager` reference repo —
one Maven project at the repo root, with `pom.xml`, `src/`, `Dockerfile`,
`Jenkinsfile`, and `k8s/` all sitting side by side.

---

## 1. Project Structure

```
college-event-site/
├── pom.xml                        # Maven build file (Spring Boot 4.1, Java 25)
├── Dockerfile                     # Builds a JDK 25 image around the Maven jar
├── Jenkinsfile                    # CI/CD pipeline: Maven build → Docker → K8s
├── .gitignore
├── src/
│   ├── main/java/com/college/techfest/
│   │   ├── TechfestApplication.java
│   │   ├── controller/
│   │   │   ├── AnnouncementController.java   # GET  /api/announcements
│   │   │   ├── RegistrationController.java   # POST /api/registrations
│   │   │   └── HealthController.java         # GET  /healthz
│   │   ├── service/
│   │   │   ├── AnnouncementService.java
│   │   │   └── RegistrationService.java
│   │   └── model/
│   │       ├── Announcement.java
│   │       └── Registration.java
│   ├── main/resources/
│   │   ├── application.properties            # server.port=8081, actuator on 9090
│   │   └── static/                            # index.html, schedule.html, speakers.html,
│   │                                           # register.html, announcements.html, css/, js/
│   └── test/java/...                          # JUnit test (Spring context load)
├── k8s/
│   ├── deployment.yaml                        # 2 replicas, liveness/readiness probes
│   └── service.yaml                           # NodePort 30081 (app), 30090 (actuator)
└── monitoring/
    ├── docker-compose.yml                     # Nagios + Graphite + Grafana, one project
    ├── nagios/objects/college-event-site.cfg
    ├── grafana/college-event-dashboard.json
    └── scripts/
        ├── push_metrics_to_graphite.ps1        # Windows (use this one)
        └── push_metrics_to_graphite.sh         # Linux/macOS (optional alternative)
```

---

## 2. Prerequisites (install once)

- Git
- **Java 25 (JDK)** and **Maven** — check with `java -version` and `mvn -version`
- Docker Desktop, with **Kubernetes enabled** (Settings → Kubernetes → Enable Kubernetes)
- `kubectl` (comes bundled with Docker Desktop's Kubernetes)
- Jenkins (local Windows install, since your pipeline uses `bat` steps)
- A GitHub account

---

## 3. Step 1 — Replace your repo contents

If you're updating your existing `College-Event-Site` repo, **delete the old
`app/`, `backend/`, `nginx.conf`, and any duplicate `Jenkinsfile`/`Dockerfile`/`k8s`
at the root**, then copy in everything from this project so the repo root
matches the structure in Section 1 exactly (one project, no nested folders).

```bash
git add .
git commit -m "Rebuild as single Maven Spring Boot project (matches taskmanager structure)"
git push
```

---

## 4. Step 2 — Build with Maven and run locally (sanity check)

```bash
mvn clean package -DskipTests
```

This produces `target/techfest-0.0.1-SNAPSHOT.jar`. Take a screenshot of this
succeeding for your report.

Run it directly to confirm it works before touching Docker:
```bash
java -jar target/techfest-0.0.1-SNAPSHOT.jar
```
Open:
- **http://localhost:8081** — Home page
- **http://localhost:8081/api/announcements** — JSON list
- **http://localhost:9090/actuator/health** — `{"status":"UP"}`

Stop with `Ctrl+C`.

---

## 5. Step 3 — Build the Docker image and test it

```bash
docker build -t techfest-backend:v1 .
docker run -d -p 8081:8081 -p 9090:9090 --name techfest-backend techfest-backend:v1
```

Open **http://localhost:8081** — take a screenshot (Docker Build/Run evidence).

```bash
docker stop techfest-backend
docker rm techfest-backend
```

---

## 6. Step 4 — Deploy to Kubernetes

```bash
kubectl get nodes                     # confirms Kubernetes is running
docker build -t techfest-backend:v1 . # make sure the image exists
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl get pods
kubectl get svc
```

Open **http://localhost:30081**.

> **If localhost:30081 doesn't load in your browser but the pods show
> `Running`,** this is a known Docker Desktop-on-Windows NodePort quirk.
> Confirm the app itself is fine first:
> ```bash
> kubectl port-forward svc/techfest-backend 8081:8081
> ```
> then open http://localhost:8081 in another terminal/browser tab. If that
> works, try **Docker Desktop → Settings → Kubernetes → Restart Kubernetes
> Cluster**, then re-test `localhost:30081`. This has been the fix in testing
> so far — if it still fails afterward, re-check Windows Firewall rules for
> Docker Desktop.

Screenshot `kubectl get pods` / `kubectl get svc` (both Running) and the
browser view — these cover the Kubernetes + Application Output requirements.

---

## 7. Step 5 — Jenkins CI/CD

1. Open Jenkins (`http://localhost:8080`).
2. New Item → Pipeline → name it `college-event-site-pipeline`.
3. Pipeline → Definition → "Pipeline script from SCM" → Git → your repo URL
   → **Script Path: `Jenkinsfile`** (root of the repo now, no `backend/` prefix).
4. Click **Build Now**.

The `Jenkinsfile` in this project uses `bat` steps throughout (confirmed
working on your machine already) and assumes `java`, `mvn`, `docker`, and
`kubectl` are all on your system PATH — no Jenkins Tool auto-installer
configuration required. If `mvn -version` fails in the "Verify Tools" stage,
add Maven's `bin` folder to your Windows PATH and restart the Jenkins service.

Take screenshots of: Jenkins Dashboard, the job configuration screen, the
Console Output of a successful build, and the green build status.

---

## 8. Step 6 — Monitoring: Nagios + Graphite + Grafana (one Compose project)

```bash
cd monitoring
docker compose up -d
```

This starts all three containers together (same as your Docker Desktop
screenshot) under a project named `monitoring`:

| Service | URL | Login |
|---|---|---|
| Nagios | http://localhost:8083/nagios | nagiosadmin / nagios |
| Graphite | http://localhost:8089 | — |
| Grafana | http://localhost:3000 | admin / admin |

### Push metrics into Graphite

From **PowerShell** (not Git Bash):
```powershell
cd monitoring\scripts
powershell -ExecutionPolicy Bypass -File push_metrics_to_graphite.ps1
```
Leave this running. Check Graphite's metrics tree
(`college_event_site → system` / `→ app`) at http://localhost:8089 — take a
screenshot.

> If `app.http_availability` always shows 0, it means `localhost:30081`
> isn't reachable from your machine yet (see the NodePort troubleshooting
> note in Step 4). Edit the `$AppUrl` line in the script to point at
> `http://localhost:8081/healthz` instead, and run
> `kubectl port-forward svc/techfest-backend 8081:8081` in another window
> while the metrics script runs.

### Set up Grafana

1. http://localhost:3000 → log in `admin`/`admin` → set a new password.
2. **Connections → Data sources → Add data source → Graphite** → URL:
   `http://graphite:80` → **Save & Test**.
3. **Dashboards → New → Import** → upload
   `monitoring/grafana/college-event-dashboard.json` → pick the Graphite
   data source → **Import**.
4. Screenshot the dashboard (CPU, Memory, Disk, Network, HTTP Availability,
   Uptime panels).

### Check Nagios

Open http://localhost:8083/nagios → **Services**. You should see host
`techfest-backend-host` with `HTTP - Website Availability` and `PING`
services. Give it 1–2 minutes for the first check cycle, then screenshot
the Service Status Details page (Host UP, Services OK).

> Nagios logging "system time change... compensating" warnings on startup is
> normal — it happens whenever the container was paused/resumed (e.g. your
> laptop slept) and is harmless; Nagios reschedules checks automatically.
> If `PING` stays in a pending/critical state, that's expected on some Docker
> Desktop networking setups (ICMP doesn't always traverse the NAT) — the
> `HTTP` service check is the one that matters for this assignment.

---

## 9. Step 7 — Cleanup

```bash
kubectl delete -f k8s/service.yaml
kubectl delete -f k8s/deployment.yaml
cd monitoring
docker compose down
```

---

## 10. Assignment Checklist Mapping

| Requirement | Where it's satisfied |
|---|---|
| Maven build | `pom.xml`, `mvn clean package` (Step 2), Jenkinsfile Maven stages (Step 5) |
| Version control / collaboration | Git repository (Step 1) |
| Automated deployment on update | `Jenkinsfile` pipeline (Step 5) |
| Docker-based hosting | `Dockerfile` (Step 3) |
| Kubernetes deployment | `k8s/deployment.yaml`, `k8s/service.yaml` (Step 4) |
| Website availability | http://localhost:30081 (NodePort Service) |
| Website availability monitoring | Nagios HTTP check (Step 6) |
| Server resource metrics collection | Graphite via `push_metrics_to_graphite.ps1` (Step 6) |
| Monitoring dashboards | Grafana dashboard: CPU, Memory, Disk, Network, Uptime (Step 6) |
