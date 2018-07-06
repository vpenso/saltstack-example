docker_registry_container:
  docker_container.running:
    - image: registry:latest
    - name: docker-registry
    - port_bindings: { 5000: 5000 }
