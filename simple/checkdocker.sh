!/bin/bash
set -ex
sudo mkdir -p /data/
sudo chmod 777 /data

containerName=$1
currTime=$(date "+%Y%m%d-%H%M%S")
exist=`docker inspect --format '{{.State.Running}}' ${containerName}`
if [ "${exist}" != "true" ]; then
 docker start ${containerName}
 echo "${currTime} restart container Name is:${containerName}" >> /data/monitor.log
fi

docker stats --no-stream >> /data/status.log