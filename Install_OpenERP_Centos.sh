#!/bin/sh
#
#  Author: Carlos E. Fonseca Zorrilla
#  Modified by: Alan Alvarado Santillán
#  Version: 0.1b
#  Date: 01/11/2013
#  Web: http://www.fonse.net
#       http://www.3rp.co
#
#  NOTE: Install OpenERP v7.0 on Centos 6.3 x64
#
#  Changelog
#  24/02/2014 v0.1b : Updated url epel repo, pgdg url, added unzip
#  01/29/2013 v0.1b : Update url epel repo, update service name
#  01/11/2013 v0.1b : First commit
#

yum -y install wget unzip
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh http://yum.pgrpms.org/9.1/redhat/rhel-6Server-x86_64/pgdg-redhat91-9.1-5.noarch.rpm
yum -y install python-psycopg2 python-lxml PyXML python-setuptools libxslt-python pytz \
            python-matplotlib python-babel python-mako python-dateutil python-psycopg2 \
            pychart pydot python-reportlab python-devel python-imaging python-vobject \
            hippo-canvas-python mx python-gdata python-ldap python-openid \
            python-werkzeug python-vatnumber pygtk2 glade3 pydot python-dateutil \
            python-matplotlib pygtk2 glade3 pydot python-dateutil python-matplotlib \
            python python-devel python-psutil python-docutils make \
            automake gcc gcc-c++ kernel-devel byacc flashplugin-nonfree \
            postgresql91-libs postgresql91-server postgresql91 libxslt-devel
service postgresql-9.1 initdb
echo "listen_addresses = '*'" >> /var/lib/pgsql/9.1/data/postgresql.conf
echo "host all all 0.0.0.0/0 md5" >> /var/lib/pgsql/9.1/data/pg_hba.conf
service postgresql-9.1 start
chkconfig postgresql-9.1 on
echo "openerp user postgresql"
su - postgres -c "createuser --pwprompt --createdb --no-createrole --no-superuser openerp"
cd /tmp
wget http://gdata-python-client.googlecode.com/files/gdata-2.0.17.zip
unzip gdata-2.0.17.zip
rm -rf gdata-2.0.17.zip
cd gdata*
python setup.py install
cd /tmp
adduser openerp
DIR="/var/run/openerp /var/log/openerp"
for NAME in $DIR
do
if [ ! -d $NAME ]; then
   mkdir $NAME
   chown openerp.openerp $NAME
fi
done
rm -rf openerp*
wget http://nightly.openerp.com/7.0/nightly/src/openerp-7.0-latest.tar.gz
tar -zxvf openerp-7.0-latest.tar.gz  --transform 's!^[^/]\+\($\|/\)!openerp\1!'
cd openerp
python setup.py install
rm -rf /usr/local/bin/openerp-server
cp openerp-server /usr/local/bin
cp install/openerp-server.init /etc/init.d/openerp
cp install/openerp-server.conf /etc
chmod u+x /etc/init.d/openerp
chkconfig openerp on
service  openerp start