#!/usr/bin/python

# SOURCE: https://apple.stackexchange.com/questions/4286/is-there-a-mac-os-x-terminal-version-of-the-free-command-in-linux-systems
import subprocess
import re
import sys

# Human readable bytes
# source: https://stackoverflow.com/questions/1094841/reusable-library-to-get-human-readable-version-of-file-size
def sizeof_fmt(num, suffix='B'):
    desired_unit = None
    if len(sys.argv) == 2:
        desired_unit = "".join(ch for ch in sys.argv[1] if ch.isalnum())

    for unit in ['','Ki','Mi','Gi','Ti','Pi','Ei','Zi']:
        if not desired_unit or abs(num) < 1024.0 or desired_unit.lower() in unit.lower():
            return "%3.1f%s%s" % (num, unit, suffix)
        num /= 1024.0
    return "%.1f%s%s" % (num, 'Yi', suffix)

def main():
    # Get process info
    ps = subprocess.Popen(['ps', '-caxm', '-orss,comm'], stdout=subprocess.PIPE).communicate()[0].decode()
    vm = subprocess.Popen(['vm_stat'], stdout=subprocess.PIPE).communicate()[0].decode()

    # Iterate processes
    processLines = ps.split('\n')
    sep = re.compile('[\s]+')
    rssTotal = 0 # kB
    for row in range(1,len(processLines)):
        rowText = processLines[row].strip()
        rowElements = sep.split(rowText)
        try:
            rss = float(rowElements[0]) * 1024
        except:
            rss = 0 # ignore...
        rssTotal += rss

    # Process vm_stat
    vmLines = vm.split('\n')
    sep = re.compile(':[\s]+')
    vmStats = {}
    for row in range(1,len(vmLines)-2):
        rowText = vmLines[row].strip()
        rowElements = sep.split(rowText)
        vmStats[(rowElements[0])] = int(rowElements[1].strip('\.')) * 4096

    print('Wired Memory:\t\t{}'.format(sizeof_fmt(vmStats["Pages wired down"])))
    print('Active Memory:\t\t{}'.format(sizeof_fmt(vmStats["Pages active"])))
    print('Inactive Memory:\t{}'.format(sizeof_fmt(vmStats["Pages inactive"])))
    print('Free Memory:\t\t{}'.format(sizeof_fmt(vmStats["Pages free"])))
    print('Real Mem Total (ps):\t{}'.format(sizeof_fmt(rssTotal)))

if __name__ == "__main__":
    main()
