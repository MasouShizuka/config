import sys
from subprocess import Popen

if __name__ == '__main__':
    if len(sys.argv) >= 4:
        Popen(['bash', 'delete.sh', *(sys.argv[1:])])
