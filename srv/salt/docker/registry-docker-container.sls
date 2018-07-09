docker_registry_container:
  docker_container.running:
    - image: registry:2.6.2
    - name: docker-registry
    - port_bindings: 
      - 5000:5000
    - restart_policy: always
