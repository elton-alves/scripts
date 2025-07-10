SSH_KEY=${HOME}/.ssh/id_rsa

agent_pid=`ps aux | grep ssh-agent | grep -v "grep" | head -n 2 | awk '{print $1}'`

if [ -z "${agent_pid}" ]; then
    eval $(ssh-agent -s)
else
	last_agentDir=`ls -lt /tmp/ssh-* | head -n 1 | awk '{split($0,a,":"); print a[1]}'`
	agent_pid_file=`ls ${last_agentDir} | awk '{split($0,a,"="); print a[1]}'`
	agent_pid=`echo ${agent_pid_file} | awk '{split($0,a,"."); print a[2]}'`
	export SSH_AUTH_SOCK=${last_agentDir}/${agent_pid_file}
	export SSH_AGENT_PID=${agent_pid}
	
	echo "SSH_AUTH_SOCK=${SSH_AUTH_SOCK}"
	echo "SSH_AGENT_PID=${SSH_AGENT_PID}"
fi

keys=`ssh-add -l`
no_keys="The agent has no identities."

if [[ $keys == "${no_keys}" ]]; then
  ssh-add ${SSH_KEY}
fi