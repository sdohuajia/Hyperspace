# Hyperspace


```bash
wget -O Hyperspace.sh https://raw.githubusercontent.com/xxxxbxxxxx/Hyperspace/refs/heads/main/Hyperspace.sh && sed -i 's/\r$//' Hyperspace.sh && chmod +x Hyperspace.sh && ./Hyperspace.sh

source /root/.bashrc && update-grub && reboot

wget -O points_monitor.sh https://raw.githubusercontent.com/xxxxbxxxxx/Hyperspace/refs/heads/main/points_monitor.sh && chmod +x points_monitor.sh

wget -O monitor.sh https://raw.githubusercontent.com/xxxxbxxxxx/Hyperspace/refs/heads/main/monitor.sh && chmod +x monitor.sh

apt-get install supervisor -y

echo -e "[program:monitor]\ncommand=/bin/bash /root/monitor.sh\nautostart=true\nautorestart=true\nstderr_logfile=/var/log/monitor.err.log\nstdout_logfile=/var/log/monitor.out.log\nstartretries=3\nstartsecs=10" > /etc/supervisor/conf.d/monitor.conf

echo -e "[program:points]\ncommand=/bin/bash /root/points_monitor.sh\nautostart=true\nautorestart=true\nstderr_logfile=/var/log/points_monitor.err.log\nstdout_logfile=/var/log/points_monitor.out.log\nstartretries=3\nstartsecs=10" > /etc/supervisor/conf.d/points.conf

supervisorctl reread
supervisorctl update

systemctl enable supervisor
```

monitor.conf

```
[program:monitor]
command=/bin/bash /root/monitor.sh
autostart=true
autorestart=true
stderr_logfile=/var/log/monitor.err.log
stdout_logfile=/var/log/monitor.out.log
startretries=3
startsecs=10
```

points.conf

```
[program:points]
command=/bin/bash /root/points_monitor.sh
autostart=true
autorestart=true
stderr_logfile=/var/log/points_monitor.err.log
stdout_logfile=/var/log/points_monitor.out.log
startretries=3
startsecs=10
```