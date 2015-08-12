#! /usr/bin/env python

import os

NOSTRICT="-o StrictHostKeyChecking=no"
MASTER="vagrant@10.10.10.3"
WORKER="vagrant@10.10.10.4"


def execute(command):
    print ("EXECUTING", command)
    os.system(command)

def scp(source, dest):
    print ("scp", source, dest)        
    os.system("scp {:} {:} {:}".format(NOSTRICT, source,dest))

def rm(filename):
    os.system("rm -f {:}".format(filename))

def sudo_ssh(host, command, background=False):
    print ("EXECUTING", host, command)
    if background:
        os.system("ssh {:} {:} sudo {:} &".format(NOSTRICT, host, command))
    else:
        os.system("ssh {:} {:} 'sudo {:}'".format(NOSTRICT, host, command)) 
    
rm("~/.ssh/known_hosts")
 
for host in [MASTER, WORKER]:
    scp("test.sh", host)


sudo_ssh(MASTER,  '/usr/sbin/create-munge-key -f')

os.system("ssh " + NOSTRICT + " " + MASTER + "' sudo cat /etc/munge/munge.key' > munge.key")

scp ("munge.key", WORKER + ":/home/vagrant/")

sudo_ssh(WORKER, 'cp ~/munge.key /etc/munge')
sudo_ssh(WORKER, 'sudo chown munge /etc/munge/munge.key')

for host in [MASTER, WORKER]:
    print "------------------"
    print "preparing " + host
    print "------------------"    
    sudo_ssh(host, 'systemctl enable --system --full munge')
    scp ("munge.service",  host + ':/home/vagrant/')
    sudo_ssh(host, 'cp ~/munge.service /etc/systemd/system/munge.service')
    sudo_ssh(host, 'sudo systemctl daemon-reload')
    sudo_ssh(host, 'sudo systemctl start munge')
    scp ("test.sh",  host + ":/home/vagrant/")

print "------------------"
print "start services"
print "------------------"    

#os.system("ssh " + MASTER + ' sudo slurmctld -D &')
#os.system("ssh " + MASTER + ' sudo slurmd &')

