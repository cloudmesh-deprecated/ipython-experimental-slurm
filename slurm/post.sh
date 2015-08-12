#! /bin/sh



rm -f ~/.ssh/known_hosts

export NOSTRICT="-o StrictHostKeyChecking=no"
export MASTER="vagrant@10.10.10.3"
export WORKER="vagrant@10.10.10.4"
export SSH="ssh $NOSTRICT"
export SCP="scp $NOSTRICT"

echo $1

case $1 in

master)

    set -x
    $SCP test.sh $MASTER
    $SSH $MASTER 'sudo /usr/sbin/create-munge-key -f'
    $SSH $MASTER 'sudo cat /etc/munge/munge.key' > munge.key
    $SCP munge.service $MASTER:/home/vagrant/
    $SSH $MASTER 'sudo cp ~/shared/munge.service /etc/systemd/system/munge.service'
    $SSH $MASTER sudo systemctl enable --system --full munge
    # $SSH $MASTER sudo systemctl daemon-reload
    $SSH $MASTER sudo systemctl start munge
    ;;

worker)
    set -x
    $SCP test.sh $WORKER
    $SCP munge.key $WORKER:/home/vagrant/
    $SSH $WORKER 'sudo cp ~/munge.key /etc/munge; sudo chown munge /etc/munge/munge.key'
    $SCP munge.service $WORKER:/home/vagrant/
    $SSH $WORKER 'sudo cp ~/shared/munge.service /etc/systemd/system/munge.service'
    $SSH $WORKER sudo systemctl enable --system --full munge
    # $SSH $WORKER sudo systemctl daemon-reload
    $SSH $WORKER sudo systemctl start munge
    ;;

sworker)
    set -x
    $SSH $WORKER sudo slurmd &
    ;;

smaster)
    set -x
    $SSH $MASTER sudo slurmctld -D &
    ;;

status)
    echo "-------------------------------------------------------------------------------"    
    echo "MASTER"
    echo "-------------------------------------------------------------------------------"        
    $SSH $MASTER systemctl status munge.service
    echo "-------------------------------------------------------------------------------"            
    echo "WORKER"
    echo "-------------------------------------------------------------------------------"
    $SSH $WORKER systemctl status munge.service
    echo "-------------------------------------------------------------------------------"
    ;;
    

esac


