## DNS setup issues

### Ubuntu/KDE Neon

https://www.reddit.com/r/pihole/comments/1gqi1hn/pihole_docker_on_ubuntu_issues_with_port_53_and/?tl=fr


### Podman/Docker Rootless setup

Allow without using sudo to bind on containers ports numbers under 1024

```bash
# Add at the end or modify if already present :
echo "net.ipv4.ip_unprivileged_port_start=53" | sudo tee /etc/sysctl.conf
```
