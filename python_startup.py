import atexit
import os
import readline

xdg_state_home = os.getenv('XDG_STATE_HOME')
if xdg_state_home is None:
    state_dir = os.path.join(os.path.expanduser("~"), ".local", "state", "python")
else:
    state_dir = os.path.join(xdg_state_home, "python")

try:
    os.makedirs(state_dir, exist_ok = True)
except TypeError:
    try:
        os.makedirs(state_dir)
    except OSError:
        pass

history_file = os.path.join(state_dir, 'history')

try:
    readline.read_history_file(history_file)
except IOError:
    pass

atexit.register(readline.write_history_file, history_file)

