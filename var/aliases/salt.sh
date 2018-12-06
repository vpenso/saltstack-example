SALT_REPO=${SALT_REPO:-https://github.com/vpenso/saltstack-example}
SALT_MASTER=${SALT_MASTER:-lxcm01}
SALT_DOCKER_LOGS=$SALT_EXAMPLE_PATH/var/log
SALT_STATE_TREE=$SALT_EXAMPLE_PATH/srv/salt

export SALT_REPO SALT_MASTER SALT_DOCKER_LOGS SALT_STATE_TREE

# create the log directory if missing
[[ -d $SALT_DOCKER_LOGS ]] || mkdir --parents $SALT_DOCKER_LOGS

salt-bootstrap-minion() {

        # on Red Hat, CentOS
        if command -v yum &>/dev/null
        then

                echo Add SaltStack repository to Yum in /etc/yum.repos.d/salt.repo
                cp $SALT_EXAMPLE_PATH/etc/yum.repos.d/salt.repo \
                   /etc/yum.repos.d/

                # enable the EPEL repository
                yum install --assumeyes epel-release \
                    &>> $SALT_DOCKER_LOGS/yum.log

                echo Install salt-minion with Yum, cf. \$SALT_DOCKER_LOGS/yum.log
                yum --assumeyes \
                    install salt-minion jq \
                    &>> $SALT_DOCKER_LOGS/yum.log
        fi

}

salt-call-local-state() {

        salt-call --local \
                  --file-root $SALT_STATE_TREE \
                  state.sls $@ \
                  |& tee -a $SALT_DOCKER_LOGS/salt.log

}

salt-call-local-state-docker() {

        echo Exec masterless Salt to install Docker CE, cf. \$SALT_DOCKER_LOGS/salt.log
        salt-call-local-state docker/docker-ce \
                  &>> $SALT_DOCKER_LOGS/salt.log

}
