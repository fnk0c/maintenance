# Maintenance
Maintenance script to backup, update and get server status

##### This script does the folliwing actions
* Backup of web server
* Backup of MySQL database
* System's update
* Check for website status

--------
##### Usage
***start***  
`sudo sh maintenance.sh start`

***status***  
`sudo sh maintenance.sh status`

***stop***  
`sudo sh maintenance.sh stop`

##### If you prefer, you can turn it into a service
* **Debian**  
`mv maintenance.sh maintenance && sudo mv maintenance /etc/init.d/`  
`service maintenance start`

* **CentOS**  

1. create a file called __maintenance.service__  
`touch maintenance.service`

2. edit the file as below  
`vim maintenance.service`   

  ```
[Unit]
Description=Maintenance script to backup, update system and retrieve website status

[Service]
Type=simple
ExecStart=/bin/bash /opt/maintenance start
ExecReload=/bin/bash /opt/maintenance reload
ExecStop=/bin/bash /opt/maintenance stop
PIDFile=/var/run/maintenance.pid
  ```

3. chmod to 644  
`chmod 644 maintenance.service`  

4. move the files  
`mv maintenance.sh  maintenance && sudo mv maintenance /opt/`  
`sudo mv maintenance.service /usr/lib/systemd/system/`  

5. reboot your system to apply the changes  
`reboot`

6. start the script  
`systemctl start maintenance`  

7. install  
`sudo systemctl enable maintenance`  
