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
Coming Soon
