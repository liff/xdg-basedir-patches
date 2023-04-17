{ pkgs, lib, ... }:

let
  data = "$HOME/.local/share";
  state = "$HOME/.local/state";
  config = "$HOME/.config";
  cache = "$HOME/.cache";

  ansibleConfig  = "${config}/ansible";
  ansibleCache   = "${cache}/ansible";
  ansibleData    = "${data}/ansible";
  ansibleState   = "${state}/ansible";
  ansiblePlugins = "${ansibleState}/plugins";

in {
  environment.sessionVariables = {
    ERRFILE       = "${cache}/x11/xsession-errors";
    XCOMPOSECACHE = "${cache}/xcompose";

    PARALLEL_HOME = "${config}/parallel";

    HISTFILE = "${state}/bash/history";

    GNUPGHOME = "${config}/gnupg";

    MYSQL_HISTFILE = "${state}/mysql/history";

    PSQLRC       = "${config}/postgresql/psqlrc";
    PSQL_HISTORY = "${state}/postgresql/history";

    __GL_SHADER_DISK_CACHE_PATH = "${cache}/nvidia";
    CUDA_CACHE_PATH             = "${cache}/nvidia";

    CARGO_HOME  = "${cache}/cargo";
    RUSTUP_HOME = "${cache}/rustup";

    STACK_ROOT   = "${cache}/stack";
    CABAL_DIR    = "${cache}/cabal";
    CABAL_CONFIG = "${config}/cabal/config";

    RANDFILE = "${cache}/openssl/rnd";

    PYTHON_EGG_CACHE   = "${cache}/python/eggs";
    IPYTHONDIR         = "${cache}/ipython";
    JUPYTER_CONFIG_DIR = "${config}/jupyter";
    PYTHONSTARTUP      = "${./python_startup.py}";
    WORKON_HOME        = "${cache}/virtualenvs";
    PYLINTHOME         = "${cache}/pylint";

    SCREENRC = "${config}/screen/rc";

    AWS_CONFIG_FILE             = "${config}/aws/config";
    AWS_SHARED_CREDENTIALS_FILE = "${config}/aws/credentials";
    BOTO_CONFIG                  = "${config}/aws/boto.ini";

    HTTPIE_CONFIG_DIR = "${config}/httpie";

    NODE_REPL_HISTORY     = "${state}/node/repl_history";
    NPM_CONFIG_USERCONFIG = "${config}/npm/npmrc";
    NPM_CONFIG_PREFIX     = "${cache}/npm";
    NVM_DIR               = "${cache}/nvm";

    SBT_ETC_FILE          = "${config}/sbt/sbtopts";
    SBT_GLOBAL_SERVER_DIR = "\$\{XDG_RUNTIME_DIR}/sbt";

    GRADLE_USER_HOME = "${cache}/gradle";

    EMACSNATIVELOADPATH = "${cache}/emacs/native";

    PACKER_CONFIG_DIR = "${config}/packer";
    PACKER_CACHE_DIR  = "${cache}/packer";

    SQLITE_HISTORY = "${state}/sqlite/history";

    DOCKER_CONFIG        = "${config}/docker";
    MACHINE_STORAGE_PATH = "${cache}/docker-machine";

    MINIKUBE_HOME = "${cache}/minikube";

    GDBHISTFILE = "${state}/gdb/history";

    SSB_HOME = "${state}/zoom";

    TEXMACS_HOME_PATH = "${state}/texmacs";

    KUBECONFIG   = "${config}/kube/config.yaml";
    KUBECACHEDIR = "${cache}/kube";

    VAULT_CONFIG_PATH = "${config}/vault/config.hcl";

    MPLAYER_HOME = "${config}/mplayer";

    GRIPHOME = "${cache}/grip";

    # Handle the Ansible disaster
    ANSIBLE_HOME = ansibleData;

    ANSIBLE_CONFIG = "${ansibleConfig}/ansible.cfg";

    ANSIBLE_REMOTE_TEMP = "/tmp";
    ANSIBLE_LOCAL_TEMP  = "${ansibleCache}/tmp";
    ANSIBLE_ASYNC_DIR   = "${ansibleCache}/async";

    ANSIBLE_SSH_CONTROL_PATH_DIR        = "\$\{XDG_RUNTIME_DIR:-${cache}}/ansible/cp";
    ANSIBLE_PERSISTENT_CONTROL_PATH_DIR = "\$\{XDG_RUNTIME_DIR:-${cache}}/ansible/pc";

    ANSIBLE_GALAXY_TOKEN_PATH = "${ansibleState}/galaxy_token";
    ANSIBLE_GALAXY_CACHE_DIR  = "${ansibleCache}/galaxy";

    ANSIBLE_COLLECTIONS_PATHS = "${ansibleData}/collections:/etc/ansible/collections";
    ANSIBLE_ROLES_PATH        = "${ansibleData}/roles:/etc/ansible/roles";

    ANSIBLE_LIBRARY      = "${ansiblePlugins}/modules";
    ANSIBLE_MODULE_UTILS = "${ansiblePlugins}/module_utils";

    ANSIBLE_DOC_FRAGMENT_PLUGINS = "${ansiblePlugins}/doc_fragments";
    ANSIBLE_ACTION_PLUGINS       = "${ansiblePlugins}/action";
    ANSIBLE_BECOME_PLUGINS       = "${ansiblePlugins}/become";
    ANSIBLE_CACHE_PLUGINS        = "${ansiblePlugins}/cache";
    ANSIBLE_CALLBACK_PLUGINS     = "${ansiblePlugins}/callback";
    ANSIBLE_CLICONF_PLUGINS      = "${ansiblePlugins}/cliconf";
    ANSIBLE_CONNECTION_PLUGINS   = "${ansiblePlugins}/connection";
    ANSIBLE_FILTER_PLUGINS       = "${ansiblePlugins}/filter";
    ANSIBLE_HTTPAPI_PLUGINS      = "${ansiblePlugins}/httpapi";
    ANSIBLE_INVENTORY_PLUGINS    = "${ansiblePlugins}/inventory";
    ANSIBLE_LOOKUP_PLUGINS       = "${ansiblePlugins}/lookup";
    ANSIBLE_NETCONF_PLUGINS      = "${ansiblePlugins}/netconf";
    ANSIBLE_STRATEGY_PLUGINS     = "${ansiblePlugins}/strategy";
    ANSIBLE_TERMINAL_PLUGINS     = "${ansiblePlugins}/terminal";
    ANSIBLE_TEST_PLUGINS         = "${ansiblePlugins}/test";
    ANSIBLE_VARS_PLUGINS         = "${ansiblePlugins}/vars";
  };
}
