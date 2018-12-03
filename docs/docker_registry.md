
# Docker Registry

Deploy a [Docker registry server][14] container:

File                                       | Description
-------------------------------------------|-----------------------------------------
[srv/salt/docker/registry-docker-container.sls][15] | Salt state file to pull & run a Docker registry container
[srv/salt/docker/docker-daemon-insecure.sls][20]    | Salt state to configure Docker daemon
[srv/salt/docker/docker-daemon-insecure.json][21]   | Docker daemon configuration file


Execute **masterless Salt to pull and run a private docker registry**. Configure the docker daemon on pull from [an insecure registry][17]:

* [prometheus-dockerhub-images-to-local-registry][22] - Copy the Prometheus and Node Exporter **container images from DockerHub to the local registry**
* [docker-list-local-repository-catalog][11] - List container repositories on the local registry
* [docker-list-local-repository-tags()][11] -  List tags for a given container repository on the local registry

```bash
vm ex lxcm01 -r '
        # exec masterless Salt to pull and run the Docker private registry container
        salt-call-local-state docker/registry-docker-container
        # allow docker daemon insecure acccess to the local registry
        salt-call-local-state docker/docker-daemon-insecure
        # pull, tag, and push prometheus and node-exporter container images
        prometheus-dockerhub-images-to-local-registry
        # list repos in local registry
        docker-list-local-repository-catalog
'
```

Alternatively login to the VM and configure the components manually:

```bash
# write the Docker daemon configuration
echo -e "{\n \"insecure-registries\" : [\"lxcm01:5000\"]\n}" > /etc/docker/daemon.json
# restart the Docker daemon for the configuration to take effect
systemctl restart docker
# start the Docker registry container
docker run -d -p 5000:5000 --restart=always --name docker-registry registry:2.6.2
# pull the Prometheus node-exporter from DockerHub
docker pull prom/node-exporter:v0.16.0
# push it to the private registry
docker tag prom/node-exporter:v0.16.0 localhost:5000/prometheus-node-exporter:v0.16.0
docker push localhost:5000/prometheus-node-exporter:v0.16.0
# do the same for the prom/prometheus container image
# list all content of the local repository
curl -s -X GET http://localhost:5000/v2/_catalog | jq '.'
```

[11]: ../var/aliases/docker.sh
[14]: https://docs.docker.com/registry/deploying/
[15]: ../srv/salt/docker/registry-docker-container.sls
[17]: https://docs.docker.com/registry/insecure/
[20]: ../srv/salt/docker/docker-daemon-insecure.sls
[21]: ../srv/salt/docker/docker-daemon-insecure.json
[22]: ../var/aliases/prometheus.sh
