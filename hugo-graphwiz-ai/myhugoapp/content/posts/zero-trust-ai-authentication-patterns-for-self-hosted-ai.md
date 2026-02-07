---
title: "Zero-Trust AI: Authentication Patterns for Self-Hosted AI"
date: 2026-03-03T00:00:00+01:00
description: "Implement Zero-Trust security for self-hosted AI infrastructure. Protect LLM endpoints with Authelia, 2FA, and API security best practices."
tags: ["Security", "Zero-Trust", "Authelia", "2FA", "AI-Security"]
categories: ["Security", "AI-Operations"]
featured: true
---

## Executive Summary

Self-hosted AI deployments (Ollama, custom RAG systems, AI microservices) expose new attack surfaces. Traditional perimeter-based security models fail because AI services are accessed from everywhere: internal applications, mobile clients, partner integrations, and API consumers.

Zero-Trust architecture—never trust, always verify—provides the security framework needed for distributed AI services. By implementing authentication (Authelia, 2FA), authorization (role-based access), and API security (rate limiting, JWT tokens), organizations protect AI infrastructure while enabling legitimate access.

This guide presents a strategic Zero-Trust implementation for self-hosted AI, focusing on practical authentication patterns using Authelia and complementary security layers.

## The Challenge

### Security Risks in Self-Hosted AI Deployments

**New Attack Vectors**:

1. **Unauthorized LLM Access**:
   - Exposed Ollama API endpoints (default port 11434) without authentication
   - Brute-force attacks on LLM inference APIs
   - Token extraction attacks (prompt injection to reveal system prompts)

2. **Data Exfiltration through AI**:
   - Malicious queries extracting training data or internal knowledge
   - Prompt injection attacks to bypass data access controls
   - AI model exploitation to retrieve sensitive information

3. **API Abuse**:
   - Unlimited queries causing resource exhaustion (DoS)
   - High-cost compute usage from external scanners
   - Automated content generation for spam/abuse

4. **Privilege Escalation**:
   - Compromised low-privilege accounts accessing admin AI endpoints
   - LLM jailbreaks bypassing content filters
   - API key theft from compromised workstations

### Why Traditional Security Fails

**Perimeter-Based Model Assumptions**:
- Internal network = trusted zone
- VPN access = authenticated user
- Once inside, access to internal services is unrestricted

**Zero-Trust Reality**:
- No network is inherently trusted
- Every request requires authentication AND authorization
- Principle of least privilege applied to every interaction

**AI-Specific Complications**:
- LLM APIs are stateless (easy to automate abuse)
- AI responses can be manipulated to extract training data
- API keys often hardcoded or improperly managed
- AI services deployed across multiple environments (dev, staging, production)

### Compliance Requirements

**Regulatory Pressures**:
- **GDPR Article 32**: Data security by design and default
- **EU AI Act**: High-risk AI systems require strong security measures
- **SOC 2**: Access controls, monitoring, and audit trails
- **NIST 800-207**: Zero Trust Architecture framework

**Business Impact of Security Incidents**:
- Data breach notification costs: €2M-€4M (GDPR fines)
- Reputation damage: 15-30% customer loss after public AI breach
- Operational disruption: AI systems taken offline during forensic investigation

## The Solution

### Zero-Trust Architecture for AI

**Core Principles**:
1. **Explicit Verification**: Every request authenticated and authorized
2. **Least Privilege**: Minimum access required for task
3. **Assume Breach**: Network not trusted; enforce security at every layer
4. **Continuous Monitoring**: All access logged and analyzed for anomalies

```
┌─────────────────────────────────────────────────────────────────┐
│                     Client Requests                         │
│  (Internal Apps, Mobile, Partners, API Consumers)               │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ├── Authentication Layer
                     │   (Authelia, 2FA, SSO)
                     │
┌────────────────────┴────────────────────────────────────────────┐
│                  Authorization Layer                          │
│  (Role-Based Access Control, Policy Enforcement)                   │
└────────────────────┬────────────────────────────────────────────┘
                     │
                     ├── API Gateway / Reverse Proxy
                     │   (Traefik, Rate Limiting, JWT Validation)
                     │
┌────────────────────┴────────────────────────────────────────────┐
│                   AI Services Layer                           │
│  (Ollama, RAG Chatbots, Vector DB, Inference APIs)               │
└─────────────────────────────────────────────────────────────────┘
```

### Technology Stack Overview

**Authentication Components**:
- **Authelia**: Self-hosted 2FA/SSO authentication (see goneuland.de guide)
- **2FA Methods**: TOTP (Google Authenticator), WebAuthn (hardware keys), Duo push
- **Identity Provider**: OpenID Connect compatible (Keycloak, Dex)
- **Session Management**: Redis-backed sessions for high availability

**Authorization Components**:
- **Role-Based Access Control (RBAC)**: Admin, Developer, User, Viewer roles
- **Policy Engine**: OPA (Open Policy Agent) for fine-grained policies
- **API Gateway**: Traefik with middleware for JWT validation and rate limiting

**Monitoring Components**:
- **Access Logs**: All authentication and authorization events logged
- **Anomaly Detection**: Detect brute-force, unusual access patterns
- **Audit Trails**: Immutable logs for compliance reporting

### Business Impact

**Security Metrics Improvement**:
| Metric | Before Zero-Trust | After Zero-Trust | Improvement |
|--------|-------------------|-------------------|-------------|
| Unauthorized API attempts | Unknown/High | 100% blocked at gateway | Complete prevention |
| Time to detect compromise | Hours/Days | Minutes (real-time alerts) | 90%+ reduction |
| Multi-factor enforcement | Partial/Inconsistent | 100% for all AI services | Complete coverage |
| Audit trail coverage | 60% | 100% | 67% increase |

**Compliance Benefits**:
- **GDPR**: Demonstrable data access controls (Article 32 compliance)
- **SOC 2**: Audit-ready access logs and RBAC documentation
- **EU AI Act**: Security measures for high-risk AI systems

**Operational Benefits**:
- Centralized authentication management
- Consistent security across all AI services
- Reduced credential management overhead
- Faster incident response (blocked at gateway)

## Technical Implementation

### Phase 1: Deploy Authelia for Authentication

**Objective**: Implement self-hosted 2FA authentication.

**Implementation Steps**:

1. **Deploy Authelia with Docker**:
   ```yaml
   # docker-compose.yml
   version: '3.8'

   services:
     authelia:
       image: authelia/authelia:latest
       volumes:
         - ./authelia/configuration:/config
         - authelia-db:/data
       ports:
         - "9091:9091"
       environment:
         - TZ=Europe/Berlin
       networks:
         - security
       restart: unless-stopped

     redis:
       image: redis:alpine
       volumes:
         - redis-data:/data
       networks:
         - security
       restart: unless-stopped

   networks:
     security:
       driver: bridge

   volumes:
     authelia-db:
     redis-data:
   ```

2. **Configure Authelia**:
   ```yaml
   # authelia/configuration/configuration.yml
   server:
     address: 'tcp://:9091'
     disable_healthcheck: false
     tls:
       certificate: /config/certs/cert.pem
       key: /config/certs/key.pem

   log:
     level: info
     format: text
     file_path: /config/authelia.log

   theme: dark

   # Storage backend
   storage:
     encryption_key: "CHANGE_THIS_TO_RANDOM_32_CHARS"
     local:
       path: /config/db.sqlite3

   # Session configuration
   session:
     name: authelia_session
     secret: "CHANGE_THIS_TO_RANDOM_64_CHARS"
     expiration: 1h
     inactivity: 15m
     remember_me: 1M
     redis:
       host: redis
       port: 6379
       database_index: 0

   # Authentication methods
   authentication_backend:
     disable_reset_password: false
     file:
       path: /config/users_database.yml

   # 2FA configuration
   totp:
     issuer: authelia.com
     period: 30s
     skew: 1

   # Access control rules
   access_control:
     default_policy: deny
     networks:
       - name: internal
         networks:
           - 10.0.0.0/8
           - 192.168.0.0/16
       - name: vpn
         networks:
           - 10.10.0.0/16
     rules:
       # Admin endpoints (require MFA)
       - domain:
           - "ai-admin.example.com"
         policy: two_factor
         subject:
           - ["group:admins"]

       # Developer API access (require 2FA)
       - domain:
           - "ai-api.example.com"
         policy: two_factor
         methods:
           - GET
           - POST
         subject:
           - ["group:developers", "group:users"]

       # Public read-only endpoints (no auth required)
       - domain:
           - "ai-public.example.com"
         policy: bypass
         resources:
           - "^/health$"
           - "^/public/.*"

       # Default deny everything else
       - domain: ".*"
         policy: deny
   ```

3. **Configure User Database**:
   ```yaml
   # authelia/configuration/users_database.yml
   users:
     alice:
       displayname: "Alice Admin"
       password: "$argon2id$v=19$m=4096,t=3,p=1$..."  # Use authelia hash
       email: alice@example.com
       groups:
         - admins
       totp:
         issuer: authelia.com
         algorithm: sha1
         digits: 6
         period: 30s
         secret: "JBSWY3DPEHPK3PXP"  # Generated during first login

     bob:
       displayname: "Bob Developer"
       password: "$argon2id$v=19$m=4096,t=3,p=1$..."
       email: bob@example.com
       groups:
         - developers
       totp:
         issuer: authelia.com
         algorithm: sha1
         digits: 6
         period: 30s
         secret: "HXDMVJECJJWSRBQ0W"  # Generated during first login
   ```

**See goneuland.de's detailed Authelia setup guide**: https://goneuland.de/authelia-zweifaktor-authentifizierung-mittels-docker-compose-und-traefik-installieren/

### Phase 2: Integrate Authelia with Traefik

**Objective**: Protect AI services with Authelia authentication.

**Implementation Steps**:

1. **Configure Traefik with Authelia Middleware**:
   ```yaml
   # traefik/dynamic/ai-services.yml
   http:
     middlewares:
       # Authelia ForwardAuth middleware
       authelia:
         forwardAuth:
           address: "http://authelia:9091/api/verify?rd=https://auth.example.com"
           trustForwardHeader: true
           authResponseHeaders:
             - "Remote-User"
             - "Remote-Groups"
             - "Remote-Email"

       # Rate limiting middleware
       rate-limit:
         rateLimit:
           average: 100  # 100 requests per second
           burst: 200

       # JWT validation middleware
       jwt-validation:
         forwardAuth:
           address: "http://jwt-validator:8080/validate"
           authResponseHeaders:
             - "X-User-Id"
             - "X-User-Role"

     routers:
       # Ollama LLM API (protected by Authelia)
       ollama-api:
         rule: "Host(`ollama.example.com`) && PathPrefix(`/api`)"
         service: ollama-service
         middlewares:
           - authelia
           - rate-limit

       # RAG Chatbot API (protected by Authelia + JWT)
       rag-chatbot:
         rule: "Host(`chatbot.example.com`) && PathPrefix(`/api`)"
         service: ragbot-service
         middlewares:
           - authelia
           - jwt-validation
           - rate-limit

       # Public health endpoint (no auth)
       health-check:
         rule: "Host(`ollama.example.com`) && Path(`/health`)"
         service: ollama-service
         priority: 1000

     services:
       ollama-service:
         loadBalancer:
           servers:
             - url: "http://ollama:11434"

       ragbot-service:
         loadBalancer:
           servers:
             - url: "http://ragbot-api:8000"
   ```

2. **Deploy AI Services with Authelia Protection**:
   ```yaml
   # Add to docker-compose.yml (main Traefik stack)
   services:
     ollama:
       image: ollama/ollama:latest
       volumes:
         - ollama-data:/root/.ollama
       networks:
         - traefik-public
       restart: unless-stopped
       labels:
         - "traefik.enable=true"
         - "traefik.http.routers.ollama.rule=Host(`ollama.example.com`)"
         - "traefik.http.routers.ollama.middlewares=authelia,rate-limit"
         - "traefik.http.services.ollama.loadbalancer.server.port=11434"

   networks:
     traefik-public:
       external: true
   ```

### Phase 3: Implement API Key Management

**Objective**: Secure programmatic access to AI services.

**Implementation Using Vault**:

1. **Deploy HashiCorp Vault**:
   ```yaml
   # Add to docker-compose.yml
   vault:
     image: hashicorp/vault:latest
     volumes:
       - vault-data:/vault/data
     ports:
       - "8200:8200"
     environment:
       - VAULT_DEV_ROOT_TOKEN_ID=myroot
       - VAULT_DEV_LISTEN_ADDRESS=0.0.0.0:8200
     networks:
       - security
       restart: unless-stopped
       cap_add:
         - IPC_LOCK

   vault-ui:
     image: djenriquez/vault-ui:latest
     environment:
       - VAULT_URL_DEFAULT=http://vault:8200
       - VAULT_AUTH_DEFAULT=token
     ports:
       - "8080:8000"
     networks:
       - security
       restart: unless-stopped
   ```

2. **Configure API Key Storage**:
   ```bash
   # Enable KV secrets engine
   vault secrets enable -path=ai-services kv

   # Store API key for RAG chatbot
   vault kv put ai-services/ragbot \
     api_key="sk-ragbot-prod-1234567890abcdef" \
     description="Production RAG Chatbot API Key" \
     created_by="alice" \
     expiration="2026-12-31T23:59:59Z"

   # Store Ollama inference API key
   vault kv put ai-services/ollama \
     api_key="sk-ollama-prod-0987654321fedcba" \
     description="Ollama Inference API Key" \
     created_by="alice" \
     expiration="2026-06-30T23:59:59Z"
   ```

3. **Retrieve API Keys in Applications**:
   ```python
   # api_key_manager.py
   import hvac
   import os

   class APIKeyManager:
       def __init__(self, vault_url="http://localhost:8200", token="myroot"):
           self.client = hvac.Client(
               url=vault_url,
               token=token
           )

       def get_api_key(self, service_name: str) -> str:
           """Retrieve API key for service"""
           try:
               response = self.client.kv.v2.read_secret_version(
                   path=f"ai-services/{service_name}"
               )
               return response['data']['data']['api_key']
           except Exception as e:
               print(f"Failed to retrieve API key: {e}")
               raise

       def rotate_api_key(self, service_name: str, new_key: str):
           """Rotate API key for service"""
           try:
               self.client.kv.v2.create_or_update_secret_version(
                   path=f"ai-services/{service_name}",
                   secret={'api_key': new_key}
               )
               print(f"Rotated API key for {service_name}")
           except Exception as e:
               print(f"Failed to rotate API key: {e}")
               raise

   # Usage
   if __name__ == "__main__":
       key_manager = APIKeyManager()

       # Get API key for RAG chatbot
       ragbot_key = key_manager.get_api_key("ragbot")
       print(f"RAG Chatbot API Key: {ragbot_key}")

       # Rotate API key
       new_key = "sk-rotated-key-" + os.urandom(16).hex()
       key_manager.rotate_api_key("ragbot", new_key)
   ```

### Phase 4: Implement Rate Limiting and Abuse Detection

**Objective**: Prevent API abuse and DoS attacks.

**Implementation Using Traefik Middleware**:

```yaml
# traefik/dynamic/rate-limits.yml
http:
  middlewares:
    # Basic rate limit (100 req/sec per IP)
    strict-rate-limit:
      rateLimit:
        average: 100
        burst: 200
        period: 1s

    # Strict rate limit for admin endpoints (10 req/sec)
    admin-rate-limit:
      rateLimit:
        average: 10
        burst: 20
        period: 1s

    # Burst protection (500 req/sec spike)
    burst-protection:
      rateLimit:
        average: 500
        burst: 1000
        period: 1s

    # IP whitelist for internal services
    ip-allowlist:
      ipWhiteList:
        sourceRange:
          - "10.0.0.0/8"
          - "192.168.0.0/16"

    # Block common attack patterns
    security-headers:
      headers:
        customFrameOptionsValue: "SAMEORIGIN"
        customReferrerPolicy: "strict-origin-when-cross-origin"
        stsSeconds: 31536000
        forceSTSHeader: true
        stsIncludeSubdomains: true
        stsPreload: true
```

**Implement Abuse Detection with Monitoring**:

```python
# abuse_detector.py
from datetime import datetime, timedelta
from collections import defaultdict

class AbuseDetector:
    def __init__(self, window_minutes=10, max_requests=1000):
        self.window = timedelta(minutes=window_minutes)
        self.max_requests = max_requests
        self.request_log = defaultdict(list)

    def log_request(self, ip_address: str, endpoint: str, timestamp: datetime = None):
        """Log incoming request"""
        if timestamp is None:
            timestamp = datetime.utcnow()

        self.request_log[ip_address].append({
            'timestamp': timestamp,
            'endpoint': endpoint
        })

        # Clean old requests
        self._cleanup_old_requests(ip_address)

    def is_abusive(self, ip_address: str) -> bool:
        """Check if IP is making too many requests"""
        self._cleanup_old_requests(ip_address)

        request_count = len(self.request_log[ip_address])

        if request_count > self.max_requests:
            print(f"ABUSE DETECTED: {ip_address} made {request_count} requests in last {self.window}")
            return True

        return False

    def _cleanup_old_requests(self, ip_address: str):
        """Remove requests outside time window"""
        cutoff_time = datetime.utcnow() - self.window

        self.request_log[ip_address] = [
            req for req in self.request_log[ip_address]
            if req['timestamp'] > cutoff_time
        ]

# Integration with Traefik (via middleware service)
# This detector would be deployed as a separate service
# and called by Traefik's ForwardAuth middleware
```

### Phase 5: Implement Audit Logging

**Objective**: Log all authentication and authorization events.

**Implementation**:

```python
# audit_logger.py
import json
from datetime import datetime
import hvac

class AuditLogger:
    def __init__(self, log_file="/var/log/ai-audit.log", vault_client=None):
        self.log_file = log_file
        self.vault_client = vault_client

    def log_event(self, event_type: str, details: dict):
        """Log security event"""
        event = {
            'timestamp': datetime.utcnow().isoformat(),
            'event_type': event_type,
            **details
        }

        # Write to file
        with open(self.log_file, 'a') as f:
            f.write(json.dumps(event) + '\n')

        # Also send to SIEM (optional)
        # self._send_to_siem(event)

    def log_authentication(self, username: str, success: bool, ip_address: str):
        """Log authentication attempt"""
        self.log_event('AUTHENTICATION', {
            'username': username,
            'success': success,
            'ip_address': ip_address,
            'method': '2FA' if success else 'Password'
        })

    def log_authorization(self, username: str, resource: str, action: str, allowed: bool):
        """Log authorization decision"""
        self.log_event('AUTHORIZATION', {
            'username': username,
            'resource': resource,
            'action': action,
            'allowed': allowed
        })

    def log_api_access(self, api_key: str, endpoint: str, success: bool):
        """Log API access"""
        self.log_event('API_ACCESS', {
            'api_key': api_key,
            'endpoint': endpoint,
            'success': success
        })

# Usage
if __name__ == "__main__":
    logger = AuditLogger()

    logger.log_authentication("alice", True, "192.168.1.100")
    logger.log_authorization("alice", "/api/ollama/generate", "POST", True)
    logger.log_api_access("sk-ragbot-123", "/api/query", True)
```

## Next Steps

### Implementation Roadmap

**Week 1-2: Authentication Foundation**
- Deploy Authelia with 2FA
- Configure user database and groups
- Integrate with Traefik as ForwardAuth middleware

**Week 3-4: Authorization & API Security**
- Define RBAC roles and policies
- Implement rate limiting middleware
- Deploy Vault for API key management

**Week 5-6: Monitoring & Detection**
- Implement abuse detection system
- Set up audit logging
- Configure alerts for security events

**Week 7-8: Testing & Hardening**
- Penetration testing of AI endpoints
- Audit access controls
- Test incident response procedures

**Week 9-10: Production Rollout**
- Gradual rollout with monitoring
- Review and adjust security policies
- Document security procedures

### Success Metrics

**Security Metrics**:
- Unauthorized access attempts blocked: 100%
- MFA enforcement coverage: 100% of AI services
- Audit trail completeness: 100% of events logged
- Rate limiting effectiveness: <1% of requests exceed limits

**Operational Metrics**:
- Time to revoke compromised credentials: <5 minutes
- False positive rate: <5% (legitimate requests blocked)
- API key rotation frequency: Every 90 days

## goneuland.de Cross-References

For hands-on setup of authentication components, refer to these goneuland.de tutorials:

**Authelia Setup**:
- https://goneuland.de/authelia-zweifaktor-authentifizierung-mittels-docker-compose-und-traefik-installieren/
- Comprehensive guide on deploying Authelia with Docker and Traefik
- Covers 2FA configuration, user management, and integration

**2FA Configuration**:
- 2FA guides and tutorials: https://goneuland.de/category/2-faktor-authentifizierung/
- Covers TOTP, WebAuthn, and Duo integration

**Why This Complements Our Approach**:
goneuland.de provides detailed technical implementation for authentication setup (Authelia configuration, 2FA methods). Our guide focuses on strategic security architecture: Zero-Trust principles, AI-specific threat modeling, and policy design. Use goneuland.de for installation details, and this guide for security strategy and risk mitigation.
