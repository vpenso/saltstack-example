{% set pxesrv_path = '/opt/pxesrv' %}

# install Docker on the host
include:
  - docker/docker-ce

# install dependency packages
pxesrv_packages:
  pkg.latest:
    - refresh: True
    - pkgs:
      - git

# clone the latest version for the repository
pxesrv_git_repo:
  git.latest:
    - name: https://github.com/vpenso/pxesrv.git
    - target: {{ pxesrv_path }}

pxesrv_docker_container:
  docker_image.present:
    - name: pxesrv
    - build: {{ pxesrv_path }}
    - tag: latest

pxesrv_docker_run:
  docker_container.running:
    - name: pxesrv
    - image: pxesrv:latest
    - restart_policy: always
    - port_bindings:
      - 4567:4567
    - binds:
      - /srv/pxesrv:/srv/pxesrv:ro
