PROMETHEUS_VERSION='v2.3.1'
PROMETHEUS_NODE_EXPORTER_VERSION='v0.16.0'

export PROMETHEUS_VERSION \
       PROMETHEUS_NODE_EXPORTER_VERSION

echo 'prometheus-docker-images-to-local-registry() -- Copy Prometheus container images to local registry'
prometheus-docker-images-to-local-registry() {
        
        echo Pull Prometheus container images from DockerHub
        docker pull prom/prometheus:$PROMETHEUS_VERSION
        docker pull prom/node-exporter:$PROMETHEUS_NODE_EXPORTER_VERSION
        
        echo Tag and push Prometheus images to local registry
        docker tag prom/prometheus:$PROMETHEUS_VERSION \
                   lxcm01:5000/prometheus:$PROMETHEUS_VERSION
        docker tag prom/node-exporter:$PROMETHEUS_NODE_EXPORTER_VERSION \
                   lxcm01:5000/prometheus-node-exporter:$PROMETHEUS_NODE_EXPORTER_VERSION 
        docker push lxcm01:5000/prometheus:$PROMETHEUS_VERSION
        docker push lxcm01:5000/prometheus-node-exporter:$PROMETHEUS_NODE_EXPORTER_VERSION

}
