Tessera Full-Spectrum Security Audit Summary
Date: 2026-05-15
Scope: Full repo (Rails app, frontend, configs, Docker, CI), static code review + local tool output (RuboCop, Bundler-Audit, Brakeman). Dynamic testing not performed.

Immediate Critical Fixes (act within 24–72 hours)
1) Enforce HTTPS + secure cookies in production (config/environments/production.rb).
2) Encrypt or replace storage of GitHub OAuth access tokens (app/controllers/oauth_controller.rb + developer_profiles.github_access_token).
3) Patch known vulnerable dependencies flagged by bundler-audit (net-imap, nokogiri) and rebuild images.

Detailed Findings

F-01: HTTPS not enforced in production (session hijacking risk)
Severity: High
CWE: CWE-319 (Cleartext Transmission), CWE-614 (Sensitive Cookie in HTTPS Session Without Secure Flag)
Location: config/environments/production.rb:30-35 (force_ssl/assume_ssl commented out)
Why vulnerable: The application does not force HTTPS or mark cookies as secure/HSTS. If any HTTP access or misconfigured load balancer occurs, session cookies can be captured or downgraded.
Exploit scenario: An attacker on the same network intercepts an HTTP request or forces a downgrade, captures a session cookie, and replays it to impersonate the user.
PoC: Visit http://<app-host>/users/sign_in (if HTTP is reachable) and capture the session cookie in a proxy; replay it to gain access.
Recommended fix: Enable force_ssl, assume_ssl behind TLS termination, and set HSTS + secure cookie flags.
Secure implementation example:
  # config/environments/production.rb
  config.assume_ssl = true
  config.force_ssl = true
  config.ssl_options = { hsts: { expires: 1.year, subdomains: true, preload: true } }

F-02: GitHub OAuth access tokens stored in plaintext
Severity: High
CWE: CWE-312 (Cleartext Storage of Sensitive Information)
Location: app/controllers/oauth_controller.rb:9-15; db/schema.rb:93 (developer_profiles.github_access_token)
Why vulnerable: Access tokens are stored unencrypted in the database. A DB leak, insider access, or backup exposure yields immediate access to users’ GitHub data (including private repos if scoped).
Exploit scenario: Attacker exfiltrates the DB, extracts github_access_token values, and uses them to access private repositories or modify code.
PoC: SELECT github_access_token FROM developer_profiles; use token in curl: curl -H "Authorization: Bearer <token>" https://api.github.com/user/repos
Recommended fix: Encrypt tokens at rest (Rails 7+ `encrypts`), minimize OAuth scopes, or switch to GitHub App with short-lived tokens.
Secure implementation example:
  # app/models/developer_profile.rb
  encrypts :github_access_token

F-03: Public passkey allowlist leaks all credential IDs
Severity: Medium
CWE: CWE-200 (Exposure of Sensitive Information)
Location: app/controllers/passkeys_controller.rb:63-74
Why vulnerable: Unauthenticated endpoint returns allow list built from Passkey.pluck(:external_id), exposing all registered credential IDs. This is privacy-sensitive and increases enumeration and targeted attacks.
Exploit scenario: Attacker calls /auth/passkeys/options and receives the list of registered credential IDs, which can be used for user enumeration or targeted phishing.
PoC: curl -X POST https://<app>/auth/passkeys/options; inspect allow list.
Recommended fix: Use discoverable credentials (omit allow list), or require a username/email to scope allow list to a single user.
Secure implementation example:
  # Only provide allow list for a specific user identity
  allow = current_user.passkeys.pluck(:external_id) # or omit entirely for resident keys

F-04: Weak password policy (minimum 6 chars)
Severity: Medium
CWE: CWE-521 (Weak Password Requirements)
Location: config/initializers/devise.rb:184 (config.password_length = 6..128)
Why vulnerable: Short passwords are easier to brute-force; combined with missing lockout/rate limiting, increases account compromise risk.
Exploit scenario: Credential stuffing and brute-force attacks succeed against weak passwords.
PoC: Attempt 6-character passwords against a known email with no lockout.
Recommended fix: Increase minimum length (>= 10–12) and require complexity or passphrase guidance.
Secure implementation example:
  config.password_length = 12..128

F-05: No account lockout / rate limiting for auth endpoints
Severity: Medium
CWE: CWE-307 (Improper Restriction of Excessive Authentication Attempts)
Location: config/initializers/devise.rb (lockable/timeoutable commented), no Rack::Attack config present
Why vulnerable: Login, password reset, and passkey endpoints are not rate-limited or locked, enabling automated credential stuffing and brute-force.
Exploit scenario: Attackers use leaked password lists to attempt logins at scale without throttling.
PoC: Send repeated login attempts to /users/sign_in or passkey endpoints without IP-based throttling.
Recommended fix: Enable Devise lockable or add Rack::Attack rate limits for login, password reset, and passkey endpoints.
Secure implementation example:
  # Gemfile: gem "rack-attack"
  # config/initializers/rack_attack.rb
  Rack::Attack.throttle('logins/ip', limit: 10, period: 60) { |req| req.ip if req.path == '/users/sign_in' && req.post? }

F-06: Account enumeration via Devise defaults
Severity: Medium
CWE: CWE-204 (Observable Discrepancy)
Location: config/initializers/devise.rb:90-94 (paranoid mode commented)
Why vulnerable: Devise will respond differently for existing vs non-existing accounts in password reset/registration flows, enabling attackers to enumerate valid emails.
Exploit scenario: Attacker enumerates user emails for phishing or credential stuffing campaigns.
PoC: Submit reset requests for known/unknown emails and compare responses.
Recommended fix: Enable Devise paranoid mode and normalize responses.
Secure implementation example:
  config.paranoid = true

F-07: URL validation allows newline/extra data injection in project_demo_url
Severity: Medium
CWE: CWE-20 (Improper Input Validation)
Location: app/models/portfolio_submission.rb:5,25 (URL_REGEX = /\Ahttps?:\/\/.+/i)
Why vulnerable: Missing end anchor allows values like "https://safe.tld\njavascript:alert(1)" to pass. These URLs are rendered into href attributes in admin/user views.
Exploit scenario: Malicious developer submits a demo URL that passes validation and is rendered in admin views, enabling XSS or open redirect tricks when clicked.
PoC: Submit project_demo_url = "https://example.com\njavascript:alert(1)" and view admin portfolio submissions.
Recommended fix: Use strict URL parsing and anchor the regex with \z, or validate with URI parsing and allowlist schemes.
Secure implementation example:
  validates :project_demo_url, format: { with: /\Ahttps?:\/\/[\S]+\z/i }, allow_blank: true

F-08: PII exposure to client-side globals and third-party telemetry
Severity: Medium
CWE: CWE-359 (Exposure of Private Information)
Location: app/views/layouts/application.html.erb:15-30; config/initializers/sentry.rb:8-13; app/frontend/entrypoints/application.js:58-62
Why vulnerable: Email/name/user ID are placed in window.__CURRENT_USER and window.__PLAIN_AUTH, then sent to Sentry/Plain. This increases data exposure and compliance scope.
Exploit scenario: Any XSS or compromised third-party script can exfiltrate user PII; telemetry vendors receive full identifiers without explicit consent controls.
PoC: Inspect window.__CURRENT_USER in the browser console as any authenticated user.
Recommended fix: Minimize PII sent to frontend, gate telemetry with consent, and hash identifiers where possible.
Secure implementation example:
  window.__CURRENT_USER = { id: current_user.id } // remove email/full name from client

F-09: CSP disabled; no defense-in-depth against XSS
Severity: Medium
CWE: CWE-693 (Protection Mechanism Failure)
Location: config/initializers/content_security_policy.rb (entire policy commented out)
Why vulnerable: Without CSP, any XSS vulnerability (present or future) results in full account compromise and data exfiltration.
Exploit scenario: A future XSS bug in a view allows attacker to run arbitrary JS and steal sessions; CSP would otherwise mitigate.
PoC: N/A (configuration issue).
Recommended fix: Enable a strict CSP with script-src nonces, disallow inline scripts, and lock down external origins.
Secure implementation example:
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.script_src  :self, :https, -> { "'nonce-#{content_security_policy_nonce}'" }
    policy.object_src  :none
    policy.frame_ancestors :none
  end

F-10: Third-party scripts loaded without integrity protection
Severity: Medium
CWE: CWE-829 (Inclusion of Functionality from Untrusted Control Sphere)
Location: app/views/layouts/application.html.erb:4; app/frontend/entrypoints/application.js:45-49
Why vulnerable: AlpineJS and Plain chat are loaded from remote CDNs without SRI or CSP. A compromised CDN or MITM in dev can inject malicious code.
Exploit scenario: Attacker compromises a CDN asset; every user executes attacker JS, exfiltrating sessions and PII.
PoC: Replace CDN response to include alert() and observe execution.
Recommended fix: Pin assets with SRI, self-host critical scripts, and enforce CSP.
Secure implementation example:
  <script src="..." integrity="sha384-..." crossorigin="anonymous"></script>

F-11: ActionMailbox engine exposed without ingress hardening
Severity: Low/Medium
CWE: CWE-284 (Improper Access Control)
Location: config/routes.rb:109 (mount ActionMailbox::Engine => "/rails/action_mailbox")
Why vulnerable: ActionMailbox routes are exposed even when ingress is not configured. Misconfiguration can allow unauthenticated inbound emails or DoS on ingestion endpoints.
Exploit scenario: Attacker posts large payloads to inbound email endpoints, causing resource exhaustion.
PoC: curl -X POST https://<app>/rails/action_mailbox/relay/inbound_emails -d @large_payload
Recommended fix: Disable the engine unless needed, or configure ingress auth and restrict to internal networks.
Secure implementation example:
  # config/routes.rb
  # mount ActionMailbox::Engine => "/rails/action_mailbox" if Rails.env.development?

F-12: Known vulnerable dependencies
Severity: High
CWE: CWE-1104 (Use of Unmaintained/Vulnerable Components)
Location: Gemfile.lock (via bundler-audit output); net-imap 0.6.3, nokogiri 1.19.2
Why vulnerable: Bundler-audit reports multiple CVEs in net-imap (STARTTLS stripping, command injection, DoS) and nokogiri (ReDoS, memory leak).
Exploit scenario: If mail ingestion or HTML parsing uses these libraries, attackers can trigger DoS or injection through crafted inputs.
PoC: See advisory links in bundler-audit output.
Recommended fix: Upgrade net-imap to >= 0.6.4 and nokogiri to >= 1.19.3, rebuild, and re-run audits.
Secure implementation example:
  gem "net-imap", ">= 0.6.4"
  gem "nokogiri", ">= 1.19.3"

Top 10 Highest Risk Issues (prioritized)
1) HTTPS not enforced (F-01)
2) Plaintext GitHub OAuth tokens (F-02)
3) Vulnerable dependencies (F-12)
4) No auth rate limiting/lockout (F-05)
5) Weak password policy (F-04)
6) Public passkey allowlist leak (F-03)
7) URL validation weakness in project_demo_url (F-07)
8) PII exposure to telemetry (F-08)
9) CSP disabled (F-09)
10) Third-party script integrity (F-10)

Hardening Recommendations (beyond fixes)
- Add structured audit logging for admin actions (impersonation, role changes, identity overrides).
- Implement centralized rate limiting for all auth endpoints (login, reset, passkeys).
- Add security headers: CSP, Permissions-Policy, X-Content-Type-Options, Referrer-Policy.
- Enable password breach checks (e.g., HaveIBeenPwned via k-anonymity).
- Evaluate GDPR/SOC2 data processing for Sentry/Plain telemetry.

Production Readiness Score (Security)
Score: 58 / 100
Rationale: Solid baseline frameworks, but high-impact gaps (HTTPS enforcement, token storage, dependency CVEs, and auth hardening) materially reduce readiness.

Security Maturity Assessment
Level: Developing (basic controls exist, but critical controls are inconsistent or missing; security tooling partially integrated).

Likely Bug Bounty Findings
- Session hijacking via HTTP downgrade (F-01).
- Plaintext OAuth token leakage (F-02).
- Auth brute-force / credential stuffing (F-05/F-04).
- CSP absence increasing XSS blast radius (F-09).

Compliance Risks (SOC2/GDPR/PCI)
- GDPR: PII exposed to third parties (Sentry/Plain) without explicit consent controls (F-08).
- SOC2: Lack of HTTPS enforcement and incomplete security monitoring for auth abuse (F-01/F-05).
- PCI: If payments are added later, weak auth controls and telemetry PII exposure could fail PCI DSS requirements.

Prioritized Remediation Roadmap
0–7 days:
- Enable HTTPS enforcement (F-01).
- Patch vulnerable dependencies (F-12).
- Encrypt OAuth tokens (F-02).

1–3 weeks:
- Add auth rate limiting + lockout policies (F-05).
- Strengthen password policy (F-04) and enable paranoid responses (F-06).
- Implement CSP + SRI for third-party scripts (F-09/F-10).

1–2 months:
- Rework passkey discovery to avoid global allowlists (F-03).
- Review telemetry and data minimization for GDPR/SOC2 (F-08).
- Restrict or remove ActionMailbox mount if unused (F-11).

Most Likely Catastrophic Breach Scenario
Scenario: An attacker captures session cookies via HTTP downgrade (F-01) and combines credential stuffing (F-05/F-04) to take over admin accounts. They then access plaintext GitHub OAuth tokens (F-02) and user PII in telemetry (F-08), escalating to source-code compromise and full data exfiltration.
Attacker difficulty: Moderate (requires network position or commodity credential stuffing).
Estimated blast radius: High — full account takeover, repo access, and PII exposure.

Exploitability Matrix
- Unauthenticated users: F-01, F-03, F-05, F-06, F-09, F-10, F-11, F-12
- Authenticated users: F-02, F-07, F-08, F-09, F-10
- Malicious admins: F-02, F-08 (telemetry data), admin actions (hardening recommendations)
- Compromised integrations: F-08, F-10
- Insiders: F-02, F-08

Executive Summary (Founder/CTO)
Tessera has a solid Rails foundation, but several high-impact security gaps materially increase breach risk. The biggest issues are: HTTPS is not enforced, GitHub OAuth tokens are stored in plaintext, and known vulnerable dependencies are present. Combined with weak authentication controls (short passwords, no lockout/rate limiting), these gaps make account takeover and data exfiltration plausible for motivated attackers. Immediate action should focus on enforcing TLS, encrypting tokens, and patching dependencies. Within the next few weeks, implement rate limiting and stronger password policies, then add CSP and tighten third-party telemetry to reduce PII exposure. Addressing these items will materially improve production readiness and reduce the likelihood of a catastrophic breach.