import subprocess
import os
from time import sleep


def run_cmd(command):
    result = subprocess.run(["cmd", "/c", command], capture_output=True, text=True)
    output = result.stdout
    error = result.stderr
    return output, error, result.returncode

def run(command_to_run, showout=True):
    output, error, return_code = run_cmd(command_to_run)
    if showout:
        print("Output:")
        print(output)
        print("Return Code:", return_code)
    if error:
        print("Error:", error)

### configs
username = '' 
address = ''  # IP or Domain
server_port = ''
local_port = '3090' # or whatever

if __name__ == "__main__":
    command = f"ssh {username}@{address} -p {server_port} -D {local_port} -N"
    while True:
        print(f'connect to "{address}"')
        run(command)
        sleep(1.5)
        os.system('cls' if os.name == 'nt' else 'clear')

    
