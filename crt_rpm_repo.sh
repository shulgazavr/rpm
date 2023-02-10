#!/bin/bash
repo_path=/repos/CentOS/7/
yum install -y curl wget rpmdevtools rpm-build
yum install -y openssl-devel zlib-devel pcre2-devel
yum install -y epel-release
yum install -y nginx createrepo
runuser -l vagrant -c "wget https://nginx.org/packages/mainline/centos/7/SRPMS/nginx-1.23.3-1.el7.ngx.src.rpm"
runuser -l vagrant -c "rpm -i nginx-1.23.3-1.el7.ngx.src.rpm"
runuser -l vagrant -c "sed -i 's/listen       80/listen       8008/g' ~/rpmbuild/SOURCES/nginx.default.conf"
runuser -l vagrant -c "rpmbuild -ba ~/rpmbuild/SPECS/nginx.spec"
mkdir -p $repo_path
createrepo $repo_path
cp /home/vagrant/rpmbuild/RPMS/x86_64/nginx-*.rpm $repo_path
createrepo $repo_path
cat << EOF > /etc/yum.repos.d/local.repo
[local]
name=Local
baseurl=file://$repo_path
enables=1
gpgcheck=0
EOF
yum install -y nginx
systemctl enable nginx --now
