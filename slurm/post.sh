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
    $SSH $MASTER sudo systemctl enable --system --full munge
    $SSH $MASTER sudo systemctl start munge
    $SSH $MASTER sudo slurmctld -D &
    ;;

worker)
    set -x
    $SCP test.sh $WORKER
    $SCP munge.key $WORKER:/home/vagrant/
    $SSH $WORKER 'sudo cp ~/munge.key /etc/munge; sudo chown munge /etc/munge/munge.key'
    $SSH $WORKER sudo systemctl enable --system --full munge
    $SSH $WORKER sudo systemctl start munge
    $SSH $WORKER sudo slurmd &
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


