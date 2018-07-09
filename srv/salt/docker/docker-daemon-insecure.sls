docker_daemon_insecure:
  file.managed:
    - name: /etc/docker/daemon.json
    - source: salt://docker/docker-daemon-insecure.json
  service.running:
    - name: docker.service
    - watch:
      - file: /etc/docker/daemon.json
