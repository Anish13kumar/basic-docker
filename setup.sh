#!/bin/sh
#services start
wg-quick up wg0 #Peer Variable
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD  -p tcp -i wg0 --dst 172.20.0.0/16
service ssh start

# htdocs symlink
mkdir /home/test/htdocs #username variable
cp /var/www/html/index.html /home/test/htdocs/
rm -rf /var/www/html
ln -s /home/test/htdocs/ /var/www/html #username variable


#apache config file symlink
mkdir /home/test/htconfig/
cp -rn /etc/apache2/sites-available/* /home/test/htconfig
rm -rf /etc/apache2/sites-available
ln -s /home/test/htconfig /etc/apache2/sites-available

# change permissions to htdocs
cd /home
chmod 775 test #username variable
chown -R test:test /home/test/htdocs #username variable
adduser www-data test #username variable
# echo "Options +FollowSymLinks +SymLinksIfOwnerMatch" > /home/test/htdocs/html/.htaccess #username variable
chmod o+x /home/test/htdocs/* #username variable

#chaning permissions to htconfig
chown -R test:test /home/test/htconfig
chown -R test:test /home/test/.bashrc

#remove password
echo "test ALL=(ALL:ALL) NOPASSWD: /usr/sbin/a2ensite" | sudo tee -a /etc/sudoers.d/test > /dev/null
echo "test ALL=(ALL:ALL) NOPASSWD: /usr/sbin/a2enmod" | sudo tee -a /etc/sudoers.d/test > /dev/null
echo "test ALL=(ALL:ALL) NOPASSWD: /usr/sbin/a2dismod" | sudo tee -a /etc/sudoers.d/test > /dev/null
echo "test ALL=(ALL:ALL) NOPASSWD: /usr/sbin/a2dissite" | sudo tee -a /etc/sudoers.d/test > /dev/null

cd /home/test
touch init.sh
chmod +x  init.sh
chown -R test:test init.sh
./init.sh

#code-server configuration
cd /home/test #username variable
mkdir .config
mkdir .config/code-server
cd .config/code-server

#username variable
whoami >> id
echo "bind-addr: 0.0.0.0:1111
auth: password
password: test@321 
cert: false" > config.yaml
service apache2 start

mkdir /home/test/.ssh
chown test:test /home/test/.ssh
chmod go-w /home/test/
chmod 700 /home/test/.ssh
touch /home/test/.ssh/authorized_keys
chmod 600 /home/test/.ssh/authorized_keys
chown test:test /home/test/.ssh/authorized_keys


su - test <<EOF
# Install NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# Install LTS version of Node.js using NVM
nvm install --lts

# Install Pyenv
curl https://pyenv.run | bash

# Run user-specific initialization script
if [ -f /home/test/init.sh ]; then
    chmod +x /home/test/init.sh
    /home/test/init.sh
fi

tail -f /dev/null
EOF