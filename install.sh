#!/bin/bash
lisensi="buycode#"
read -p "Masukan Kode Lisensi: " lc
if [ "$lc" = "$lisensi" ]; then
ip=$(curl -s icanhazip.com)
else
echo
echo "Kode Lisensi Salah!!"
echo 
exit 0
fi
read -p "Masukan Port Yang Untuk Proxy: " port

yum -y update
yum -y install squid
yum -y install httpd-tools
systemctl enable squid
mv /etc/squid/squid.conf /etc/squid/conf.bak
cat >> /etc/squid/squid.conf <<-END
acl SSL_ports port 443
acl Safe_ports port 80          # http
acl Safe_ports port 21          # ftp
acl Safe_ports port 443         # https
acl Safe_ports port 70          # gopher
acl Safe_ports port 210         # wais
acl Safe_ports port 1025-65535  # unregistered ports
acl Safe_ports port 280         # http-mgmt
acl Safe_ports port 488         # gss-http
acl Safe_ports port 591         # filemaker
acl Safe_ports port 777         # multiling http
acl CONNECT method CONNECT

http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports

http_port $port
coredump_dir /var/spool/squid

refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern (Release|Packages(.gz)*)$      0       20%     2880
refresh_pattern .               0       20%     4320
					
auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid/passwords
auth_param basic realm proxy
acl authenticated proxy_auth REQUIRED
http_access allow authenticated

ident_lookup_access deny all
http_access deny all
END

clear

sudo touch /etc/squid/passwords
sudo chmod 777 /etc/squid/passwords
read -p "Buat Username Proxy: " user
sudo htpasswd -c /etc/squid/passwords $user
sleep 4
clear
systemctl restart squid
echo ""
echo "Proxy Berhasil Dibuat!!"
echo "=============================="
echo "proxy : $ip:$port"
echo "=============================="
echo "gunakan user dan pass yang kamu buat!"
echo ""
