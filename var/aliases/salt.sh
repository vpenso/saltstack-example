SALT_DOCKER_LOGS=$SALT_DOCKER_PATH/var/log

export SALT_DOCKER_LOGS

echo SALT_DOCKER_LOGS=$SALT_DOCKER_LOGS

# create the log directory if missing
[[ -d $SALT_DOCKER_LOGS ]] || mkdir --parents $SALT_DOCKER_LOGS

echo 'salt-bootstrap-minion() -- Install salt-minion on localhost'
salt-bootstrap-minion() {

        # on Red Hat, CentOS
        if command -v yum &>/dev/null
        then
                echo Add SaltStack repository to Yum in /etc/yum.repos.d/salt.repo
                cp $SALT_DOCKER_PATH/etc/yum.repos.d/salt.repo \
                   /etc/yum.repos.d/
                echo Install salt-minion with Yum, cf. \$SALT_DOCKER_LOGS/yum.log
                yum --assumeyes \
                    install salt-minion \
                    &> $SALT_DOCKER_LOGS/yum.log
        fi

}

echo 'salt-call-local-state() -- Exec masterless Salt for with given SLS'
salt-call-local-state() {
        salt-call --local \
                  --file-root $SALT_DOCKER_PATH/srv/salt \
                  state.sls $@
}

echo 'salt-call-local-state-docker() -- Install Docker CE on localhost'
salt-call-local-state-docker() {
        # run a masterless salt-minion
        echo Exec masterless Salt to install Docker CE, cf. \$SALT_DOCKER_LOGS/salt.log
        salt-call-local-state docker/docker-ce \
                  &>> $SALT_DOCKER_LOGS/salt.log
}
