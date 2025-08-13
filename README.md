# Smart Fire Alert System – Dockerised Deployment

This repository contains a Flask-based web application and supporting utilities that together form the **Smart Fire Alert System**.  The instructions below show you how to build and run the project entirely inside a Docker container.

---

## 1. Prerequisites

* [Docker ≥ 20.10](https://docs.docker.com/get-docker/) or compatible engine.
* (Optional) [Docker Buildx](https://docs.docker.com/buildx/working-with-buildx/) if you need to cross-compile for an **ARM** based Raspberry-Pi.
* A MySQL (or MariaDB) instance populated with the schema from `src/on-duty.sql` / `src/off-duty.sql`.

---

## 2. Build the Image

```bash
# Clone the repository (if you have not already)
# git clone <this-repo>.git && cd Smart_FireAlert_System

# Make sure Docker is running and then build
# The image will be tagged as `smart-fire-alert:latest`
docker build -t smart-fire-alert:latest .
```

**Tip:** When targeting Raspberry-Pi hardware use:

```bash
docker buildx build --platform linux/arm/v7 -t smart-fire-alert:latest .
```

---

## 3. Run the Container

```bash
docker run -d \
  --name smart-fire-alert \
  -p 5000:5000 \
  -e SQLALCHEMY_DATABASE_URI="mysql+pymysql://webapp:<password>@<db-host>:3306/firefighters" \
  smart-fire-alert:latest
```

* The service listens on **port 5000** inside the container. `-p 5000:5000` exposes it on the host.
* A custom database connection URL can be supplied via the `SQLALCHEMY_DATABASE_URI` environment variable.  When omitted the default found in `src/App.py` is used.

### Live-reloading for Development

For interactive debugging you can mount the source tree and run the Flask development server instead:

```bash
docker run --rm -it \
  -p 5000:5000 \
  -v $(pwd):/app \
  -e FLASK_ENV=development \
  smart-fire-alert:latest \
  python src/App.py
```

---

## 4. Public API End-points

| Method | Path                     | Description                 |
| ------ | ------------------------ | --------------------------- |
| GET    | `/`                      | Landing page                |
| GET    | `/page2.html`-`/page6.html` | Static UI pages            |
| GET    | `/api/fire-status`       | Returns current fire status |

### Example – Query Fire Status

```bash
curl http://localhost:5000/api/fire-status
# → {"value": 0, "status": "success"}
```

The exact JSON schema is:

```json
{
  "value": 0|1,           // 1 when fire detected
  "status": "success"|"error",
  "message": "...optional error text..."
}
```

---

## 5. Working With the Telegram & Camera Components

* **Telegram:** `src/RemoteAccess.py` contains a helper that uses the Telegram Bot API.  Configure your own `TOKEN` and `chat_id` before using.
* **Camera:** `picamera2` relies on the Raspberry-Pi camera stack.  If you do not require camera functionality simply comment out the related imports.

---

## 6. Production Suggestions

1. Replace the default `CMD` with Gunicorn for multi-worker performance:
   ```Dockerfile
   CMD ["gunicorn", "--bind", "0.0.0.0:5000", "src.App:app"]
   ```
2. Inject secrets via **Docker Secrets** or another secrets manager; never bake them into the image.
3. Use **docker-compose** or **Kubernetes** for orchestrating the web service, MySQL, monitoring etc.

---

## 7. Troubleshooting

* *Import errors*: Ensure all hardware-specific libraries are available on your target architecture.
* *Database connection*: Check network reachability and credentials.
* *Picamera2 not found*: You may be building the image on a non-Raspberry-Pi; disable camera functionality or use an ARM base image.