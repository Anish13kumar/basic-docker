#!/bin/sh
#services start
wg-quick up wg0 #Peer Variable
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD  -p tcp -i wg0 --dst 172.20.0.0/16
service ssh start

# htdocs symlink
mkdir /home/dep/htdocs #username variable
cp /var/www/html/index.html /home/dep/htdocs/
rm -rf /var/www/html
ln -s /home/dep/htdocs/ /var/www/html #username variable


#apache config file symlink
mkdir /home/dep/htconfig/
cp -rn /etc/apache2/sites-available/* /home/dep/htconfig
rm -rf /etc/apache2/sites-available
ln -s /home/dep/htconfig /etc/apache2/sites-available

# change permissions to htdocs
cd /home
chmod 775 dep #username variable
chown -R dep:dep /home/dep/htdocs #username variable
adduser www-data dep #username variable
# echo "Options +FollowSymLinks +SymLinksIfOwnerMatch" > /home/dep/htdocs/html/.htaccess #username variable
chmod o+x /home/dep/htdocs/* #username variable

#chaning permissions to htconfig
chown -R dep:dep /home/dep/htconfig
chown -R dep:dep /home/dep/.bashrc

#remove password
echo "dep ALL=(ALL:ALL) NOPASSWD: /usr/sbin/a2ensite" | sudo tee -a /etc/sudoers.d/dep > /dev/null
echo "dep ALL=(ALL:ALL) NOPASSWD: /usr/sbin/a2enmod" | sudo tee -a /etc/sudoers.d/dep > /dev/null
echo "dep ALL=(ALL:ALL) NOPASSWD: /usr/sbin/a2dismod" | sudo tee -a /etc/sudoers.d/dep > /dev/null
echo "dep ALL=(ALL:ALL) NOPASSWD: /usr/sbin/a2dissite" | sudo tee -a /etc/sudoers.d/dep > /dev/null

cd /home/dep
touch init.sh
chmod +x  init.sh
chown -R dep:dep init.sh
./init.sh

#code-server configuration
cd /home/dep #username variable
mkdir .config
mkdir .config/code-server
cd .config/code-server

#username variable
whoami >> id
echo "bind-addr: 0.0.0.0:1111
auth: password
password: dep@321 
cert: false" > config.yaml
service apache2 start

mkdir /home/dep/.ssh
chown dep:dep /home/dep/.ssh
chmod go-w /home/dep/
chmod 700 /home/dep/.ssh
touch /home/dep/.ssh/authorized_keys
chmod 600 /home/dep/.ssh/authorized_keys
chown dep:dep /home/dep/.ssh/authorized_keys


su - dep <<EOF
# Install NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Install LTS version of Node.js using NVM
nvm install --lts

# Install Pyenv
curl https://pyenv.run | bash

# Run user-specific initialization script
if [ -f /home/dep/init.sh ]; then
    chmod +x /home/dep/init.sh
    /home/dep/init.sh
fi

tail -f /dev/null
EOF