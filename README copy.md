# D&T SSC Cloud Engineer Assignment - Note-Taking API

A scalable and secure REST API solution for cloud deployment, implementing a basic Note-Taking API with comprehensive cloud infrastructure design and CI/CD pipeline.

## 🏗️ Architecture Overview

### Cloud Architecture (GCP)

```
┌─────────────────────────────────────────────────────────────────┐
│                          Internet                                │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                  Load Balancer                                  │
│                 (Cloud Armor)                                   │
└─────────────────────┬───────────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────────┐
│                   Cloud Run                                     │
│                 (Notes API)                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Container: FastAPI + Python                              │   │
│  │ - Auto-scaling (0-10 instances)                          │   │
│  │ - Service Account with minimal permissions               │   │
│  │ - Health checks & probes                                 │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      │ (Private Network)
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                      VPC Network                                │
│  ┌─────────────────────┐    ┌─────────────────────────────────┐ │
│  │   Cloud SQL         │    │    Secret Manager               │ │
│  │   (PostgreSQL 15)   │    │    - Database passwords        │ │
│  │   - Private IP only │    │    - API keys                   │ │
│  │   - SSL enabled     │    │    - Encrypted at rest         │ │
│  │   - Automated backup│    └─────────────────────────────────┘ │
│  └─────────────────────┘                                        │
└─────────────────────────────────────────────────────────────────┘
```

### Security Features
- **Network Security**: Private VPC with no public IPs for database
- **Identity & Access Management**: Service accounts with minimal permissions
- **Secrets Management**: Database credentials stored in Secret Manager
- **SSL/TLS**: End-to-end encryption
- **Rate Limiting**: Cloud Armor protection against DDoS
- **Container Security**: Trivy vulnerability scanning in CI/CD

## 🚀 Local Setup Instructions

### Prerequisites
- Docker and Docker Compose installed
- Git for cloning the repository

### Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd notes-api
   ```

2. **Start the application**
   ```bash
   docker-compose up -d
   ```

3. **Verify the services are running**
   ```bash
   docker-compose ps
   ```

4. **Access the API**
   - API Base URL: http://localhost:8000
   - Interactive API Documentation: http://localhost:8000/docs
   - Alternative API Docs: http://localhost:8000/redoc

## 📚 API Usage

### Base URL
```
http://localhost:8000
```

### Endpoints

#### 1. Create a Note
```bash
curl -X POST "http://localhost:8000/notes" \
     -H "Content-Type: application/json" \
     -d '{
       "title": "My First Note",
       "content": "This is the content of my first note"
     }'
```

#### 2. Get All Notes
```bash
curl -X GET "http://localhost:8000/notes"
```

#### 3. Get a Specific Note
```bash
curl -X GET "http://localhost:8000/notes/1"
```

#### 4. Update a Note
```bash
curl -X PUT "http://localhost:8000/notes/1" \
     -H "Content-Type: application/json" \
     -d '{
       "title": "Updated Note Title",
       "content": "Updated content"
     }'
```

#### 5. Delete a Note
```bash
curl -X DELETE "http://localhost:8000/notes/1"
```

### Example Response
```json
{
  "id": 1,
  "title": "My First Note",
  "content": "This is the content of my first note",
  "created_at": "2025-08-27T10:30:00Z",
  "updated_at": "2025-08-27T10:30:00Z"
}
```

## 🏛️ Design Choices & Justifications

### Cloud Compute Service: Cloud Run
**Chosen: Google Cloud Run**

**Justifications:**
- **Serverless**: Pay-per-use model, scales to zero when not in use
- **Fully Managed**: No infrastructure management required
- **Container-Native**: Direct Docker deployment
- **Auto-scaling**: Handles traffic spikes automatically (0-10 instances)
- **Cost-Effective**: Ideal for variable workloads
- **Fast Cold Starts**: Optimized for stateless applications

**Alternatives Considered:**
- **GKE**: Overkill for simple API, higher operational complexity
- **Compute Engine**: Requires manual scaling and maintenance
- **App Engine**: Less flexible for containerized applications

### Database: Cloud SQL (PostgreSQL)
**Justifications:**
- **Fully Managed**: Automated backups, updates, and maintenance
- **ACID Compliance**: Ensures data consistency for note operations
- **Performance**: Optimized for transactional workloads
- **Security**: Private IP, SSL encryption, IAM integration
- **Scalability**: Can scale vertically as needed

### CI/CD Tool: GitHub Actions
**Justifications:**
- **Integrated**: Native GitHub integration
- **Cost-Effective**: Free for public repositories, competitive pricing
- **Flexibility**: Supports custom workflows and third-party actions
- **Security**: Built-in secrets management and security scanning
- **Community**: Large ecosystem of pre-built actions

**Pipeline Stages:**
1. **Code Quality**: Linting (flake8), formatting (black), import sorting (isort)
2. **Testing**: Unit tests with coverage reporting
3. **Security**: Vulnerability scanning with Trivy
4. **Build**: Docker image creation and registry push
5. **Infrastructure**: Terraform deployment with state management
6. **Deploy**: Application deployment to Cloud Run

### Security Considerations

#### Network Security
- **Private VPC**: Isolated network environment
- **Private IP**: Database not accessible from internet
- **Subnet Segmentation**: Separate ranges for services and pods
- **Cloud Armor**: DDoS protection and rate limiting

#### Identity & Access Management
- **Service Accounts**: Principle of least privilege
- **IAM Roles**: Granular permissions (cloudsql.client, secretmanager.secretAccessor)
- **No Default Credentials**: Explicit service account assignment

#### Secrets Management
- **Secret Manager**: Encrypted storage for sensitive data
- **Environment Variables**: Secure injection into containers
- **Rotation**: Support for credential rotation
- **Access Logging**: Audit trail for secret access

#### Application Security
- **Container Scanning**: Trivy vulnerability detection
- **SSL/TLS**: End-to-end encryption
- **Input Validation**: Pydantic model validation
- **Error Handling**: Secure error responses without information leakage

### Trade-offs & Alternatives

#### Cost vs. Performance
- **Current**: Cloud Run (pay-per-use) + Cloud SQL (small instance)
- **Alternative**: Preemptible GKE cluster for cost optimization
- **Trade-off**: Chose simplicity and managed services over cost optimization

#### Availability vs. Cost
- **Current**: Single-zone deployment
- **Alternative**: Multi-zone with read replicas for higher availability
- **Trade-off**: Balanced cost with acceptable availability for demo

#### Security vs. Accessibility
- **Current**: Public API with rate limiting
- **Alternative**: API Gateway with authentication
- **Trade-off**: Chose accessibility for demo while maintaining basic security

#### Development Speed vs. Production Readiness
- **Current**: SQLite for testing, PostgreSQL for production
- **Alternative**: PostgreSQL for all environments
- **Trade-off**: Faster local development with appropriate production setup

## 🔧 Development

### Running Tests
```bash
# Install development dependencies
pip install -r requirements.txt

# Run tests
pytest tests/ -v

# Run with coverage
pytest tests/ -v --cov=app --cov-report=html
```

### Code Quality
```bash
# Format code
black app/

# Sort imports
isort app/

# Lint code
flake8 app/
```

### Local Development
```bash
# Start only the database
docker-compose up -d db

# Run the API locally (for development)
export DATABASE_URL="postgresql://postgres:password@localhost:5432/notesdb"
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## 📁 Project Structure
```
.
├── app/                     # Application source code
│   ├── __init__.py
│   ├── main.py             # FastAPI application
│   ├── models.py           # SQLAlchemy models
│   ├── schemas.py          # Pydantic schemas
│   └── database.py         # Database configuration
├── tests/                  # Test files
│   ├── __init__.py
│   └── test_api.py         # API tests
├── infrastructure/         # Terraform IaC
│   └── main.tf            # GCP infrastructure
├── .github/               # GitHub Actions workflows
│   └── workflows/
│       └── ci-cd.yml      # CI/CD pipeline
├── docker-compose.yml     # Local development setup
├── Dockerfile            # Container configuration
├── requirements.txt      # Python dependencies
├── init.sql             # Database initialization
└── README.md           # This file
```

## 🚀 Deployment

### Prerequisites for Cloud Deployment
1. GCP Project with billing enabled
2. APIs enabled: Cloud Run, Cloud SQL, Secret Manager, VPC
3. Service Account with Terraform permissions
4. GitHub repository secrets configured

### GitHub Secrets Required
```
GCP_PROJECT_ID: Your GCP project ID
GCP_SA_KEY: Service account key JSON (base64 encoded)
```

### Terraform State Management
```bash
# Create bucket for Terraform state
gsutil mb gs://your-terraform-state-bucket
```

### Manual Deployment
```bash
cd infrastructure/
terraform init
terraform plan -var="project_id=your-project-id"
terraform apply
```

## 📊 Monitoring & Observability

### Built-in Monitoring
- **Cloud Run Metrics**: Request rate, latency, error rate
- **Cloud SQL Monitoring**: Connection count, CPU usage, disk I/O
- **Health Checks**: Startup and liveness probes

### Recommended Additions
- **Cloud Monitoring**: Custom metrics and alerting
- **Cloud Logging**: Centralized log aggregation
- **Error Reporting**: Automatic error detection and grouping
- **Cloud Trace**: Distributed tracing for performance analysis

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Run quality checks
5. Submit a pull request

## 📝 License

This project is created for the D&T SSC Cloud Engineer Assignment.

---

**Assignment Completed By:** [Your Name]  
**Date:** August 27, 2025  
**Company:** Deloitte & Touche Shared Service Center
