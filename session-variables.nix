{ pkgs, lib, ... }:

let
  inherit (lib) mkDefault;

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
    ERRFILE       = mkDefault "${cache}/x11/xsession-errors";
    XCOMPOSECACHE = mkDefault "${cache}/xcompose";

    PARALLEL_HOME = mkDefault "${cache}/parallel";

    HISTFILE = mkDefault "${state}/bash/history";

    GNUPGHOME = mkDefault "${config}/gnupg";

    MYSQL_HISTFILE = mkDefault "${state}/mysql/history";

    PSQLRC       = mkDefault "${config}/postgresql/psqlrc";
    PSQL_HISTORY = mkDefault "${state}/postgresql/history";

    __GL_SHADER_DISK_CACHE_PATH = mkDefault "${cache}/nvidia";
    CUDA_CACHE_PATH             = mkDefault "${cache}/nvidia";

    CARGO_HOME  = mkDefault "${cache}/cargo";
    RUSTUP_HOME = mkDefault "${cache}/rustup";

    STACK_ROOT   = mkDefault "${cache}/stack";
    CABAL_DIR    = mkDefault "${cache}/cabal";
    CABAL_CONFIG = mkDefault "${config}/cabal/config";

    RANDFILE = mkDefault "${cache}/openssl/rnd";

    PYTHON_EGG_CACHE   = mkDefault "${cache}/python/eggs";
    IPYTHONDIR         = mkDefault "${cache}/ipython";
    JUPYTER_CONFIG_DIR = mkDefault "${config}/jupyter";
    PYTHONSTARTUP      = mkDefault "${./python_startup.py}";
    WORKON_HOME        = mkDefault "${cache}/virtualenvs";
    PYLINTHOME         = mkDefault "${cache}/pylint";

    SCREENRC = mkDefault "${config}/screen/rc";

    AWS_CONFIG_FILE             = mkDefault "${config}/aws/config";
    AWS_SHARED_CREDENTIALS_FILE = mkDefault "${config}/aws/credentials";
    BOTO_CONFIG                 = mkDefault "${config}/aws/boto.ini";

    HTTPIE_CONFIG_DIR = mkDefault "${config}/httpie";

    NODE_REPL_HISTORY     = mkDefault "${state}/node/repl_history";
    NPM_CONFIG_USERCONFIG = mkDefault "${config}/npm/npmrc";
    NPM_CONFIG_PREFIX     = mkDefault "${cache}/npm";
    NVM_DIR               = mkDefault "${cache}/nvm";

    SBT_ETC_FILE          = mkDefault "${config}/sbt/sbtopts";
    SBT_GLOBAL_SERVER_DIR = mkDefault "\$\{XDG_RUNTIME_DIR}/sbt";

    GRADLE_USER_HOME = mkDefault "${cache}/gradle";

    EMACSNATIVELOADPATH = mkDefault "${cache}/emacs/native";

    PACKER_CONFIG_DIR = mkDefault "${config}/packer";
    PACKER_CACHE_DIR  = mkDefault "${cache}/packer";

    SQLITE_HISTORY = mkDefault "${state}/sqlite/history";

    DOCKER_CONFIG        = mkDefault "${config}/docker";
    MACHINE_STORAGE_PATH = mkDefault "${cache}/docker-machine";

    MINIKUBE_HOME = mkDefault "${cache}/minikube";

    GDBHISTFILE = mkDefault "${state}/gdb/history";

    TEXMACS_HOME_PATH = mkDefault "${state}/texmacs";

    KUBECONFIG   = mkDefault "${config}/kube/config.yaml";
    KUBECACHEDIR = mkDefault "${cache}/kube";

    VAULT_CONFIG_PATH = mkDefault "${config}/vault/config.hcl";

    MPLAYER_HOME = mkDefault "${config}/mplayer";

    GRIPHOME = mkDefault (
      pkgs.writeTextFile {
        name = "griphome";
        destination = "/settings.py";
        text = ''
          CACHE_DIRECTORY = '${cache}/grip'
        '';
      });

    KONAN_DATA_DIR = mkDefault "${cache}/konan";

    GRC_PREFS_PATH = mkDefault "${config}/gnuradio/grc.conf";

    PM2_HOME = mkDefault "${cache}/pm2";

    # Dart language server or something
    ANALYZER_STATE_LOCATION_OVERRIDE = mkDefault "${cache}/dartServer";

    # Flutter
    PUB_CACHE = mkDefault "${cache}/flutter-pub";
    FLUTTER_SUPPRESS_ANALYTICS = "true";

    # Handle the Ansible disaster
    ANSIBLE_HOME = mkDefault ansibleData;

    ANSIBLE_CONFIG = mkDefault "${ansibleConfig}/ansible.cfg";

    ANSIBLE_REMOTE_TEMP = mkDefault "/tmp";
    ANSIBLE_LOCAL_TEMP  = mkDefault "${ansibleCache}/tmp";
    ANSIBLE_ASYNC_DIR   = mkDefault "${ansibleCache}/async";

    ANSIBLE_SSH_CONTROL_PATH_DIR        = mkDefault "\$\{XDG_RUNTIME_DIR:-${cache}}/ansible/cp";
    ANSIBLE_PERSISTENT_CONTROL_PATH_DIR = mkDefault "\$\{XDG_RUNTIME_DIR:-${cache}}/ansible/pc";

    ANSIBLE_GALAXY_TOKEN_PATH = mkDefault "${ansibleState}/galaxy_token";
    ANSIBLE_GALAXY_CACHE_DIR  = mkDefault "${ansibleCache}/galaxy";

    ANSIBLE_COLLECTIONS_PATHS = mkDefault "${ansibleData}/collections:/etc/ansible/collections";
    ANSIBLE_ROLES_PATH        = mkDefault "${ansibleData}/roles:/etc/ansible/roles";

    ANSIBLE_LIBRARY      = mkDefault "${ansiblePlugins}/modules";
    ANSIBLE_MODULE_UTILS = mkDefault "${ansiblePlugins}/module_utils";

    ANSIBLE_DOC_FRAGMENT_PLUGINS = mkDefault "${ansiblePlugins}/doc_fragments";
    ANSIBLE_ACTION_PLUGINS       = mkDefault "${ansiblePlugins}/action";
    ANSIBLE_BECOME_PLUGINS       = mkDefault "${ansiblePlugins}/become";
    ANSIBLE_CACHE_PLUGINS        = mkDefault "${ansiblePlugins}/cache";
    ANSIBLE_CALLBACK_PLUGINS     = mkDefault "${ansiblePlugins}/callback";
    ANSIBLE_CLICONF_PLUGINS      = mkDefault "${ansiblePlugins}/cliconf";
    ANSIBLE_CONNECTION_PLUGINS   = mkDefault "${ansiblePlugins}/connection";
    ANSIBLE_FILTER_PLUGINS       = mkDefault "${ansiblePlugins}/filter";
    ANSIBLE_HTTPAPI_PLUGINS      = mkDefault "${ansiblePlugins}/httpapi";
    ANSIBLE_INVENTORY_PLUGINS    = mkDefault "${ansiblePlugins}/inventory";
    ANSIBLE_LOOKUP_PLUGINS       = mkDefault "${ansiblePlugins}/lookup";
    ANSIBLE_NETCONF_PLUGINS      = mkDefault "${ansiblePlugins}/netconf";
    ANSIBLE_STRATEGY_PLUGINS     = mkDefault "${ansiblePlugins}/strategy";
    ANSIBLE_TERMINAL_PLUGINS     = mkDefault "${ansiblePlugins}/terminal";
    ANSIBLE_TEST_PLUGINS         = mkDefault "${ansiblePlugins}/test";
    ANSIBLE_VARS_PLUGINS         = mkDefault "${ansiblePlugins}/vars";
  };
}
