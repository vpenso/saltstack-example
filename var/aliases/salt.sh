SALT_REPO=${SALT_REPO:-https://github.com/vpenso/saltstack-example}
SALT_MASTER=${SALT_MASTER:-lxcm01}
SALT_DOCKER_LOGS=$SALT_EXAMPLE_PATH/var/log
SALT_STATE_TREE=$SALT_EXAMPLE_PATH/srv/salt

export SALT_REPO SALT_MASTER SALT_DOCKER_LOGS SALT_STATE_TREE

# create the log directory if missing
[[ -d $SALT_DOCKER_LOGS ]] || mkdir --parents $SALT_DOCKER_LOGS

salt-local() {

        salt-call --local \
                  --file-root $SALT_STATE_TREE \
                  state.sls $@ \
                  |& tee -a $SALT_DOCKER_LOGS/salt.log

}
