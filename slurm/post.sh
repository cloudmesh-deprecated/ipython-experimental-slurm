#! /usr/bin/env python
    
rm -f ~/.ssh/known_hosts


 

export NOSTRICT="-o StrictHostKeyChecking=no"
export MASTER="vagrant@10.10.10.3"
export WORKER="vagrant@10.10.10.4"
export SSH="ssh $NOSTRICT"

scp $NOSTRICT test.sh $MASTER
scp $NOSTRICT test.sh $WORKER



ssh $NOSTRICT $MASTER 'sudo /usr/sbin/create-munge-key -f'
ssh $NOSTRICT $MASTER 'sudo cat /etc/munge/munge.key' > munge.key

scp $NOSTRICT munge.key $WORKER:/home/vagrant/
ssh $NOSTRICT $WORKER 'sudo cp ~/munge.key /etc/munge; sudo chown munge /etc/munge/munge.key'


ssh $NOSTRICT $WORKER sudo systemctl enable --system --full munge
ssh $NOSTRICT $MASTER sudo systemctl enable --system --full munge

scp $NOSTRICT munge.service $WORKER:/home/vagrant/
scp $NOSTRICT munge.service $MASTER:/home/vagrant/

ssh $NOSTRICT $WORKER 'sudo cp ~/munge.service /etc/systemd/system/munge.service'
ssh $NOSTRICT $MASTER 'sudo cp ~/munge.service /etc/systemd/system/munge.service'

$SSH $WORKER sudo systemctl daemon-reload
$SSH $MASTER sudo systemctl daemon-reload

$SSH $WORKER sudo systemctl start munge
$SSH $MASTER sudo systemctl start munge

scp $NOSTRICT test.sh $WORKER:/home/vagrant/
scp $NOSTRICT test.sh $MASTER:/home/vagrant/


$SSH $MASTER sudo slurmctld -D &
$SSH $CONTROLER sudo slurmd &

