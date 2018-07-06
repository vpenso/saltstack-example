docker_build_salt_master:
  docker_image.present:
    - name: salt-master
    - build: {{ salt['environ.get']('SALT_DOCKER_PATH') }}/var/dockerfiles/salt-master
    - tag: salt-master
