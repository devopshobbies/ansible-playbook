# ==========================================
# GitLab External Domain
# ==========================================
# REPLACE 'gitlab.example.com' with your actual domain
external_url 'https://gitlab.example.com'

# ==========================================
# Initial Root Password
# ==========================================
# REPLACE 'YOUR_PASSWORD' with your desired root password
gitlab_rails['initial_root_password'] = 'YOUR_PASSWORD'
gitlab_rails['display_initial_root_password'] = false
gitlab_rails['store_initial_root_password'] = false

# ==========================================
# GitLab Nginx Config
# ==========================================
nginx['enable'] = true
nginx['client_max_body_size'] = '250m'
nginx['redirect_http_to_https'] = false
nginx['gzip_enabled'] = true
nginx['listen_port'] = 80
nginx['listen_https'] = false
nginx['proxy_protocol'] = false

# ==========================================
# GitLab Email Server Settings (SMTP)
# ==========================================
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.gmail.com"
gitlab_rails['smtp_port'] = 587
# REPLACE WITH YOUR GMAIL ADDRESS
gitlab_rails['smtp_user_name'] = "your_email@gmail.com" 
# REPLACE WITH YOUR GMAIL APP PASSWORD
gitlab_rails['smtp_password'] = "your_app_password"
gitlab_rails['smtp_domain'] = "smtp.gmail.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = false
gitlab_rails['smtp_openssl_verify_mode'] = 'peer'

# ==========================================
# GitLab Security (Rack Attack)
# ==========================================
gitlab_rails['rack_attack_git_basic_auth'] = {
  'enabled' => true,
  'ip_whitelist' => [""],
  'maxretry' => 10,
  'findtime' => 60,
  'bantime' => 3600
}

# ==========================================
# Backup Settings
# ==========================================
gitlab_rails['manage_backup_path'] = true
gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"
gitlab_rails['backup_archive_permissions'] = 0644
gitlab_rails['backup_keep_time'] = 604800
gitlab_rails['env'] = {
    "SKIP" => "registry"
}
gitlab_rails['backup_multipart_chunk_size'] = 104857600

# ==========================================
# Container Registry Settings
# ==========================================
# REPLACE 'registry.example.com' with your actual registry domain
registry_external_url 'https://registry.example.com'

registry_nginx['enable'] = true
registry_nginx['listen_port'] = 5001
registry_nginx['listen_https'] = false
registry_nginx['proxy_set_headers'] = {
  "Host" => "$http_host",
  "X-Real-IP" => "$remote_addr",
  "X-Forwarded-For" => "$proxy_add_x_forwarded_for",
  "X-Forwarded-Proto" => "https",
  "X-Forwarded-Ssl" => "on"
}

# ==========================================
# Disable Unused Services (Memory Optimization)
# ==========================================
node_exporter['enable'] = false
redis_exporter['enable'] = false
postgres_exporter['enable'] = false
pgbouncer_exporter['enable'] = false
gitlab_exporter['enable'] = false
letsencrypt['enable'] = false
prometheus['enable'] = false
monitoring_role['enable'] = false
alertmanager['enable'] = false
