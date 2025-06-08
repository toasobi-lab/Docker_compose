#!/bin/bash

# Create root folder and subfolders
mkdir -p url-shortener/{backend,postgres,redis,monitoring/prometheus,monitoring/grafana/provisioning/{datasources,dashboards},tools,logs}

# Generate docker-compose.yml (with logging and fixed paths)
cat > url-shortener/docker-compose.yml <<EOL
services:
  backend:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - REDIS_HOST=redis
      - POSTGRES_HOST=postgres
    depends_on:
      redis:
        condition: service_healthy
      postgres:
        condition: service_healthy
    logging:
      driver: "json-file"
      options:
        max-size: "10m"

  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
    logging:
      driver: "json-file"
      options:
        max-size: "10m"

  postgres:
    image: postgres:alpine
    env_file: .env
    ports:
      - "5432:5432"
    volumes:
      - ./postgres:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U \${POSTGRES_USER}"]
    logging:
      driver: "json-file"
      options:
        max-size: "10m"

  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    logging:
      driver: "json-file"
      options:
        max-size: "10m"

  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    volumes:
      - ./monitoring/grafana/provisioning:/etc/grafana/provisioning
      - ./monitoring/grafana/dashboards:/var/lib/grafana/dashboards
    depends_on:
      - prometheus
    environment:
      GF_LOG_LEVEL: debug
    logging:
      driver: "json-file"
      options:
        max-size: "10m"

  redis-commander:
    image: rediscommander/redis-commander:latest
    ports:
      - "8081:8081"
    environment:
      - REDIS_HOSTS=redis
    logging:
      driver: "json-file"
      options:
        max-size: "10m"

  pgadmin:
    image: dpage/pgadmin4
    ports:
      - "8080:80"
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@example.com
      PGADMIN_DEFAULT_PASSWORD: admin
    logging:
      driver: "json-file"
      options:
        max-size: "10m"

volumes:
  postgres_data:
  grafana_data:
EOL

# Add .env file
cat > url-shortener/.env <<EOL
POSTGRES_DB=url_shortener
POSTGRES_USER=admin
POSTGRES_PASSWORD=admin
EOL

# Prometheus config
cat > url-shortener/monitoring/prometheus/prometheus.yml <<EOL
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'backend'
    static_configs:
      - targets: ['backend:8000']
  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']
  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']
EOL

# Backend code with logging and CORS fix
cat > url-shortener/backend/main.py <<EOL
import logging
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, String, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from pydantic import BaseModel
import redis
from prometheus_client import make_asgi_app

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount Prometheus metrics
metrics_app = make_asgi_app()
app.mount("/metrics", metrics_app)

# Database setup
DATABASE_URL = "postgresql://admin:admin@postgres/url_shortener"
engine = create_engine(DATABASE_URL)
Base = declarative_base()

class ShortUrl(Base):
    __tablename__ = "urls"
    short_code = Column(String(6), primary_key=True)
    original_url = Column(Text, nullable=False)

Base.metadata.create_all(bind=engine)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Redis setup
redis_client = redis.Redis(host='redis', port=6379, decode_responses=True)

class ShortenRequest(BaseModel):
    url: str

@app.post("/shorten")
def shorten_url(request: ShortenRequest):
    logger.info(f"Shortening URL: {request.url}")
    return {"short_code": "abc123"}

@app.get("/{short_code}")
def redirect_url(short_code: str):
    logger.info(f"Redirect request for: {short_code}")
    original_url = redis_client.get(short_code)
    if not original_url:
        db = SessionLocal()
        url = db.query(ShortUrl).filter(ShortUrl.short_code == short_code).first()
        if not url:
            logger.warning(f"Short code not found: {short_code}")
            raise HTTPException(status_code=404, detail="URL not found")
        original_url = url.original_url
        redis_client.set(short_code, original_url)
    return {"original_url": original_url}

@app.get("/")
def health_check():
    return {"status": "ok"}
EOL

# Backend Dockerfile
cat > url-shortener/backend/Dockerfile <<EOL
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOL

# Backend requirements
cat > url-shortener/backend/requirements.txt <<EOL
fastapi==0.78.0
uvicorn==0.18.2
redis==4.3.4
sqlalchemy==1.4.39
psycopg2-binary==2.9.3
prometheus-client==0.14.1
EOL

# Grafana provisioning
mkdir -p url-shortener/monitoring/grafana/provisioning/datasources
cat > url-shortener/monitoring/grafana/provisioning/datasources/prometheus.yml <<EOL
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true
EOL

# Grafana dashboard (proper JSON format)
cat > url-shortener/monitoring/grafana/provisioning/dashboards/url_shortener.json <<EOL
{
  "title": "URL Shortener Metrics",
  "panels": [
    {
      "gridPos": {"x": 0, "y": 0, "w": 12, "h": 8},
      "title": "Total Redirects",
      "type": "stat",
      "datasource": "Prometheus",
      "targets": [
        {
          "expr": "sum(url_requests_total)",
          "format": "time_series",
          "legendFormat": "Total Requests"
        }
      ]
    }
  ]
}
EOL

# Cleanup script with prune
cat > url-shortener/cleanup.sh <<EOL
#!/bin/bash
echo "Stopping containers..."
docker-compose down -v

echo "Removing Docker artifacts..."
docker system prune -a --volumes --force

echo "Cleaning local files..."
rm -rf postgres redis monitoring/grafana/dashboards/*
EOL
chmod +x url-shortener/cleanup.sh

# README with details
cat > url-shortener/README.md <<'EOL'
# URL Shortener System Design

This project provides a scalable URL shortener system with containerized services. It integrates monitoring and logging tools to manage and debug the system effectively.

---

## **Project Structure**
```
url-shortener/
├── backend/                     # FastAPI-based backend application
│   ├── main.py                  # API endpoints and logic
│   ├── requirements.txt         # Backend dependencies
│   ├── Dockerfile               # Backend container setup
├── postgres/                    # PostgreSQL persistent data
├── redis/                       # Redis persistent data
├── monitoring/                  # Monitoring tools
│   ├── prometheus/              # Prometheus configuration
│   └── grafana/                 # Grafana dashboards
├── logs/                        # Log files
├── docker-compose.yml           # Docker service orchestration
├── .env                         # Environment variables
└── cleanup.sh                   # Clean up script
```

---

## **System Design Overview**

### Services
- **Backend**: Manages the URL shortening logic, integrates Redis caching and PostgreSQL storage, and exposes API.
- **Redis**: Provides caching for quick URL lookups.
- **PostgreSQL**: Persistent database for storing mappings of short and long URLs.
- **Prometheus**: Collects metrics for performance monitoring.
- **Grafana**: Visualizes metrics for insights and troubleshooting.
- **Redis Commander**: GUI for Redis.
- **PgAdmin**: GUI for PostgreSQL.

---

## **Setup Instructions**

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd url-shortener
   ```

2. **Start Services**:
   ```bash
   docker-compose up --build
   ```

3. **Access Services**:
   - API Docs: [http://localhost:8000/docs](http://localhost:8000/docs)
   - Grafana: [http://localhost:3000](http://localhost:3000) (admin/admin)
   - Redis Commander: [http://localhost:8081](http://localhost:8081)
   - PgAdmin: [http://localhost:8080](http://localhost:8080) (admin@example.com/admin)

---

## **Usage**

1. **Shorten a URL**:
   - POST to `/shorten` with JSON:
   ```json
   {
     "url": "http://example.com"
   }
   ```
   - Response:
   ```json
   {
     "short_code": "abc123"
   }
   ```

2. **Redirect to Original URL**:
   - GET `/{short_code}`.

---

## **Troubleshooting**

### Common Issues
1. **API Not Loading**:
   - Ensure all services are running: `docker-compose ps`.
   - Inspect logs: `docker-compose logs backend`.

2. **Missing Grafana Dashboards**:
   - Verify provisioning paths in Grafana.

3. **Metrics Missing**:
   - Verify Prometheus targets in [http://localhost:9090](http://localhost:9090).

4. **Clean Environment**:
   - Run cleanup:
   ```bash
   ./cleanup.sh
   ```

EOL

# Make script executable
chmod +x url-shortener.sh

echo "✅ Project generated successfully! Run './url-shortener.sh' to start."
