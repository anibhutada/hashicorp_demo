#!/bin/bash
sudo yum install mailx -y
sudo cat /var/lib/jenkins/secrets/initialAdminPassword> jpwd.txt
mail -s "Jenkins Admin Pswd" brypayty_50@yahoo.com < /home/ec2-user/jpwd.txt
