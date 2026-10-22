#!/usr/bin/env python3
import sys, os

args = sys.argv[1:]

if 'ensurepip' in args:
    sys.exit(0)

if len(args) > 1 and args[0] == '-m' and args[1] == 'venv':
    target_dir = args[2] if len(args) > 2 else 'venv'
    os.makedirs(os.path.join(target_dir, 'bin'), exist_ok=True)
    os.makedirs(os.path.join(target_dir, 'lib'), exist_ok=True)
    os.makedirs(os.path.join(target_dir, 'include'), exist_ok=True)
    
    wrapper_path = os.path.expanduser('~/.local/bin/python3')
    bin_python = os.path.join(target_dir, 'bin', 'python')
    if not os.path.exists(bin_python):
        os.symlink(wrapper_path, bin_python)
    bin_python3 = os.path.join(target_dir, 'bin', 'python3')
    if not os.path.exists(bin_python3):
        os.symlink(wrapper_path, bin_python3)
        
    cfg_path = os.path.join(target_dir, 'pyvenv.cfg')
    with open(cfg_path, 'w') as f:
        f.write('home = /usr/bin\n')
        f.write('include-system-site-packages = false\n')
        f.write('version = 3.12.3\n')
    sys.exit(0)

os.execvp('/usr/bin/python3', ['python3'] + args)
