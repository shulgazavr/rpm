# Домашнее задание по теме: Управление пакетами. Дистрибьюция софта.

### Описание задания:
- Создать свой RPM (можно взять свое приложение, либо собрать, к примеру, апач с определенными опциями);
- Создать свой репо и разместить там свой RPM;
- Реализовать это все либо в вагранте, либо развернуть у себя через nginx и дать ссылку на репо.

### Краткое описание реализованного проекта:
1. Создать rpm-пакет прокси-сервера Nginx последней версией (на данный момент 1.23.3), в котором изменить порт по умолчанию 80 на 8008.
2. Использовать [Vagrantfile](https://app.vagrantup.com/centos/boxes/7).
3. Создать локальный репозиторий с собранным RPM.
4. Создать скрипт, выполняющий сборку rpm, инициализации локального репозитория и установки nginx последней версии. Добавить его вызов в Vagrantfile.


### Ход работы:
1. Подготовка:
```
yum install -y curl wget rpmdevtools rpm-build
```
```
yum install -y openssl-devel zlib-devel pcre2-devel
```
```
yum install -y epel-release
```
```
yum install -y nginx createrepo
```

2. Загрузка src файлов ngnix, установка:
```
wget https://nginx.org/packages/mainline/centos/7/SRPMS/nginx-1.23.3-1.el7.ngx.src.rpm
```
```
rpm -i nginx-1.23.3-1.el7.ngx.src.rpm
```
3. Изменение порта по умолчанию 80 на 8008.

Для этого необходимо в в файле `~/rpmbuild/SOURCES/nginx.default.conf` внести изменения директивы `listen`, в блоке `server`:
```
server {
    listen       8008;
...
}
```
4. Запуск сборки:
```
rpmbuild -ba rpmbuild/SPECS/nginx.spec
```
Проверка наличия файлов после сборки:
```
ls -lah ./rpmbuild/RPMS/x86_64/
total 2,6M
drwxr-xr-x. 2 vagrant vagrant   98 фев 10 10:47 .
drwxrwxr-x. 3 vagrant vagrant   20 фев 10 10:47 ..
-rw-rw-r--. 1 vagrant vagrant 803K фев 10 10:47 nginx-1.23.3-1.el7.ngx.x86_64.rpm
-rw-rw-r--. 1 vagrant vagrant 1,8M фев 10 10:47 nginx-debuginfo-1.23.3-1.el7.ngx.x86_64.rpm
```
5. Создание локального репозитория:

Проверка установленной версии:
```
nginx -v
nginx version: nginx/1.20.1
```
Создание каталога и запуск генерацию метаданных репозитория:
```
sudo mkdir -p /repos/CentOS/7/
```
```
sudo createrepo /repos/CentOS/7/
Saving Primary metadata
Saving file lists metadata
Saving other metadata
Generating sqlite DBs
Sqlite DBs complete
```
Копирование файлов в хранилище репозитория, проверка, перегенерация метаданных:
```
sudo cp ~/rpmbuild/RPMS/x86_64/nginx-*.rpm /repos/CentOS/7/
```
```
ls -la /repos/CentOS/7/         
total 2628
drwxr-xr-x. 3 root root     114 фев 10 11:14 .
drwxr-xr-x. 3 root root      15 фев 10 10:55 ..
-rw-r--r--. 1 root root  821564 фев 10 11:14 nginx-1.23.3-1.el7.ngx.x86_64.rpm
-rw-r--r--. 1 root root 1862372 фев 10 11:14 nginx-debuginfo-1.23.3-1.el7.ngx.x86_64.rpm
drwxr-xr-x. 2 root root    4096 фев 10 10:55 repodata
```
```
sudo createrepo /repos/CentOS/7/
Spawning worker 0 with 2 pkgs
Workers Finished
Saving Primary metadata
Saving file lists metadata
Saving other metadata
Generating sqlite DBs
Sqlite DBs complete
```
Создание конфигурационного файла для локального репозитория `/etc/yum.repos.d/local.repo` с содержимым:
```
[local]
name=Local
baseurl=file:///repos/CentOS/7/
enables=1
gpgcheck=0
```
Установка nginx из локального репозитория
```
sudo yum install -y nginx
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: ftp.nluug.nl
 * epel: epel.mirror.wearetriple.com
 * extras: centos.mirror.liteserver.nl
 * updates: mirror.sitbv.nl
Resolving Dependencies
--> Running transaction check
---> Package nginx.x86_64 1:1.20.1-10.el7 will be updated
---> Package nginx.x86_64 1:1.23.3-1.el7.ngx will be an update
--> Finished Dependency Resolution

Dependencies Resolved

=================================================================================================================================================
 Package                        Arch                            Version                                     Repository                      Size
=================================================================================================================================================
Updating:
 nginx                          x86_64                          1:1.23.3-1.el7.ngx                          local                          802 k

Transaction Summary
=================================================================================================================================================
Upgrade  1 Package

Total download size: 802 k
Is this ok [y/d/N]: y
Downloading packages:
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Updating   : 1:nginx-1.23.3-1.el7.ngx.x86_64                                                                                               1/2 
  Cleanup    : 1:nginx-1.20.1-10.el7.x86_64                                                                                                  2/2 
  Verifying  : 1:nginx-1.23.3-1.el7.ngx.x86_64                                                                                               1/2 
  Verifying  : 1:nginx-1.20.1-10.el7.x86_64                                                                                                  2/2 

Updated:
  nginx.x86_64 1:1.23.3-1.el7.ngx                                                                                                                

Complete!
```
Запуск и проверка:
```
systemctl start nginx
```
```
nginx -v
nginx version: nginx/1.23.3
```
```
ss -tlnp | grep 8008
LISTEN     0      128          *:8008                     *:* 
```
