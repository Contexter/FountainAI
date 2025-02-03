# Security Note: Bearer Authentication for GitHub Proxy APIs

## Overview
This document outlines the security considerations for using Bearer Authentication in the GitHub Proxy APIs within the FountainAI system. It highlights potential risks, mitigation strategies, and implementation best practices.

---

## Bearer Authentication Basics
Bearer tokens are used to authenticate API requests. A Bearer token must be included in the `Authorization` header as follows:

```
Authorization: Bearer <your-token>
```

The token grants access to the specified resources within the API based on the token's scope and permissions.

---

## Compatibility with GitHub Personal Access Tokens (PATs)
Bearer Authentication is fully compatible with GitHub's Personal Access Tokens (PATs). These tokens can be generated directly from GitHub and used in the `Authorization` header for secure API authentication. PATs allow granular scope definition, enhancing security by granting only the necessary permissions.

---

## Security Risks
1. **Token Leakage**
   - Tokens may be exposed through logs, URLs, or client-side code, making them vulnerable to unauthorized access.
2. **Replay Attacks**
   - Captured tokens can be reused by attackers to impersonate valid users.
3. **Over-privileged Tokens**
   - Tokens with excessive permissions can lead to data compromise if misused.
4. **Long-Lived Tokens**
   - Tokens that do not expire quickly pose extended security risks.

---

## Mitigation Strategies
### 1. **Secure Transmission:**
   - Use HTTPS to encrypt communication between clients and servers.

### 2. **Minimal Permissions:**
   - Generate tokens with the least privileges necessary for the specific task (e.g., repo-level scopes).

### 3. **Short-Lived Tokens:**
   - Use tokens with shorter lifespans and refresh them periodically.

### 4. **Token Storage:**
   - Store tokens securely in environment variables or secret vaults. Avoid embedding them directly in code.

### 5. **Token Rotation:**
   - Regularly rotate tokens and revoke old ones when no longer needed.

### 6. **IP Whitelisting:**
   - Restrict token usage to specific IP ranges for additional security.

### 7. **Monitoring and Logging:**
   - Enable logs for all API activities and monitor usage for suspicious behavior.

---

## Implementation in FountainAI OpenAPI
### Security Scheme Configuration:
```yaml
components:
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

security:
  - BearerAuth: []
```

### Dynamic Token Injection:
1. Use environment variables to securely store the token.
2. Inject the token dynamically into the `Authorization` header at runtime.

---

## Example Usage
**cURL Example:**
```
curl -X GET \
  https://issues.pm.fountain.coach/repos/{owner}/{repo}/issues \
  -H 'Authorization: Bearer YOUR_TOKEN_HERE'
```

---

## Final Recommendations
- Never expose tokens publicly (e.g., in Git repositories).
- Use GitHub's personal access tokens (PATs) with minimal scopes for specific tasks.
- Regularly audit API usage and access permissions.

By following these practices, Bearer Authentication can be securely implemented while minimizing risks in the FountainAI system.

