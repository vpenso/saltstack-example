PROMETHEUS_VERSION='v2.3.1'
PROMETHEUS_NODE_EXPORTER_VERISON='v0.16.0'

export PROMETHEUS_VERSION \
       PROMETHEUS_NODE_EXPORTER_VERSION

echo 'prometheus-docker-images-to-local-registry() -- Copy Prometheus container images to local registry'
prometheus-docker-images-to-local-registry() {
        echo Pull Prometheus container images from DockerHub
        docker pull prom/prometheus:$PROMETHEUS_VERSION
        docker pull prom/node-exporter:$PROMETHEUS_NODE_EXPORTER_VERSION
        echo Tag and push Prometheus images to local registry
        docker tag prometheus:$PROMETHEUS_VERSION $DOCKER_REGISTRY lxcm01:5000/prometheus
        docker tag node-exporter:$PROMETHEUS_NODE_EXPORTER_VERSION lxcm01:5000/node-exporter 
        docker push lxcm01:5000/prometheus
        docker push lxcm01:5000/node-exporter
}
