# D&T Cloud Engineer Assignment

###### 1: APPLICATION ######

## Local Setup

Prerequisites
- Docker and Docker Compose installed
- Git for cloning the repository

1. Clone the repository
2. Start the application
   docker-compose up -d
3. Verify the services are running
   docker-compose ps

4. Access the API
   - API Base URL: http://localhost:8000
   - Interactive API: http://localhost:8000/docs
   - Alternative API Docs: http://localhost:8000/redoc

### Endpoints
#### 1. Create a Note
curl -X POST "http://localhost:8000/notes" \
     -H "Content-Type: application/json" \
     -d '{
       "title": "My First Note",
       "content": "This is the content of my first note"
     }'

#### 2. Get All Notes
 curl -X GET "http://localhost:8000/notes"

#### 3. Get a Specific Note
curl -X GET "http://localhost:8000/notes/1"


#### 4. Update a Note
curl -X PUT "http://localhost:8000/notes/1" \
     -H "Content-Type: application/json" \
     -d '{
       "title": "Updated Note Title",
       "content": "Updated content"
     }'

#### 5. Delete a Note
curl -X DELETE "http://localhost:8000/notes/1"

### Example Response
json
{
  "id": 1,
  "title": "My First Note",
  "content": "This is the content of my first note",
  "created_at": "2025-09-05T10:30:00Z",
  "updated_at": "2025-09-05T10:30:00Z"
}

### Running Tests
pip install -r requirements.txt

#### Run tests
pytest tests/ -v

#### Run with coverage
pytest tests/ -v --cov=app --cov-report=html

#### Code Quality
# Format code
black app/

# Sort imports
isort app/

# Lint code
flake8 app/

### Local Development
# Start only the database
docker-compose up -d db

### Run the API locally (for development)
export DATABASE_URL="postgresql://postgres:password@localhost:5432/notesdb"
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

## Project Structure
![Repository](repository.png)


###### 2: Cloud Infra Design ######

### Cloud Architecture (GCP)
![Cloud Architecture](cloud_architecture.png)

Security Features
- Network Security: Private VPC with no public IPs for database
- Identity & Access Management: Service accounts with minimal permissions (least privilige)
- Secrets Management: Database credentials stored in Secret Manager
- SSL/TLS: End-to-end encryption
- Rate Limiting: Cloud Armor protection against DDoS
- Container Security: Trivy vulnerability scanning in CI/CD

## Design Choices & Justifications

### Cloud Compute Service: Cloud Run
**Google Cloud Run**

**Justifications:**
- Serverless: Pay-per-use model, scales to zero when not in use
- Fully Managed: No infrastructure management required
- Container-Native: Direct Docker deployment
- Auto-scaling: Handles traffic spikes automatically (0-10 instances)
- Cost-Effective: Ideal for variable workloads
- Fast Cold Starts: Optimized for stateless applications

Alternatives Considered:
- GKE: Overkill for simple API, higher operational complexity
- Compute Engine: Requires manual scaling and maintenance
- App Engine: Less flexible for containerized applications

### Database: Cloud SQL (PostgreSQL)
**Justifications:**
- Fully Managed: Automated backups, updates, and maintenance
- ACID Compliance: Ensures data consistency for note operations
- Performance: Optimized for transactional workloads
- Security: Private IP, SSL encryption, IAM integration
- Scalability: Can scale vertically as needed

#### Identity & Access Management
- Service Accounts: Principle of least privilege
- IAM Roles: Granular permissions (cloudsql.client, secretmanager.secretAccessor)
- No Default Credentials: Explicit service account assignment

#### Secrets Management
- Secret Manager: Encrypted storage for sensitive data
- Environment Variables: Secure injection into containers
- Rotation: Support for credential rotation
- Access Logging: Audit trail for secret access

#### Application Security
- Container Scanning: Trivy vulnerability detection
- SSL/TL*: End-to-end encryption
- Input Validation: Pydantic model validation
- Error Handling: Secure error responses without information leakage

### Trade-offs & Alternatives

#### Cost vs. Performance
- Current: Cloud Run (pay-per-use) + Cloud SQL (small instance)
- Alternative: Preemptible GKE cluster for cost optimization
- Trade-off: Chose simplicity and managed services over cost optimization

#### Availability vs. Cost
- Current: Single-zone deployment
- Alternative: Multi-zone with read replicas for higher availability
- Trade-off: Balanced cost with acceptable availability for demo

#### Security vs. Accessibility
- Current: Public API with rate limiting
- Alternative: API Gateway with authentication
- Trade-off: Chose accessibility for demo while maintaining basic security

### Monitoring & Observability

#### Built-in Monitoring
- Cloud Run Metrics: Request rate, latency, error rate
- Cloud SQL Monitoring: Connection count, CPU usage, disk I/O
- Health Checks: Startup and liveness probes

#### Other monitoring&logging tools to consider
- Cloud Monitoring: Custom metrics and alerting
- Cloud Logging: Centralized log aggregation
- Error Reporting: Automatic error detection and grouping
- Cloud Trace: Distributed tracing for performance analysis


###### 3: DevOps - CI/CD Pipeline Design ######

# CI/CD Tool: GitHub Actions
Justifications:
- Integrated: Native GitHub integration
- Cost-Effective: Free for public repositories, competitive pricing
- Flexibility: Supports custom workflows and third-party actions
- Security: Built-in secrets management and security scanning

Pipeline Stages:
1. Code Quality: Linting (flake8), formatting (black), import sorting (isort)
2. Testing: Unit tests with coverage reporting
3. Security: Vulnerability scanning with Trivy
4. Build: Docker image creation and registry push
5. Infrastructure: Terraform deployment with state management
6. Deploy: Application deployment to Cloud Run


Additional things to consider overall:
Multiple environments in the cloud (for example: a dev-staging-prod setup). This would isolate development and testing from production. This should be managed by terraform (keeping the resources (projects, IAM, resources etc. consistent. Seperate state file for each environment)). For a small project like this it's not worth to implement a whole landing zone, but for enterprise grade workloads it would be worth it in the long run - multiple applications under development would require a massive architectural design (Google offers an "out of the box" solution for a landing zone, called Fast Fabric with multiple stages).

For critical applications (where outages must be avoided at all costs) a multi region deployment is ideal, as it decreases the chance for outage, providing more stability.

Semantic versioning: automate versioning inside the CI/CD pipeline, changelog generation based on commit messages. (example tool: semantic-release)

Enhancing the workflow: deploy to staging from the develop branch and require manual approval (code review) before deploying to production from the main branch. 

Deployment strategies (canary/blue-green): when multiple versions of the application exist, traffic splitting between versions is ideal (for zero-downtime releases and rollbacks). 

A disaster recovery plan could be designed for emergencies, to restore/roll back to a previous state.
An "exit plan" could also be worked upon, where all resources from the cloud provider (in this case GCP) could be migrated to another cloud provider (for eg. Azure/AWS). This all depends on business needs and compliance.

