docker_build_salt_master:
  docker_image.present:
    - name: salt-master
    - build: {{ salt['environ.get']('SALT_DOCKER_PATH') }}/var/dockerfiles/salt-master
    - tag: latest

docker_run_salt_master:
  docker_container.running:
    - name: salt-master
    - image: salt-master:latest
    - restart_policy: always
    - port_bindings:
      - 4505:4505
      - 4506:4506
    - binds: 
      - {{ salt['environ.get']('SALT_DOCKER_PATH') }}/srv/salt:/srv/salt:ro
