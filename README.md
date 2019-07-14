# docker-oraclejdk

#### 项目介绍
docker-oraclejdk

support os:
1. alpine:curl bash openssh wget net-tools gettext zip unzip tzdata ncurses git subversion
2. centos:passwd openssl openssh-server wget net-tools gettext zip unzip ncurses git subversion

support tool
1. sshd, jdk, jre, git, svn
2. apphome: /data/app
3. jdkhome: /data/jdk
4  jrehome: /data/jdk/jre
5. user: root/admin; app/123456
6. usage:
docker run -it --rm --name java-1.8.192-alpine registry.cn-hangzhou.aliyuncs.com/rancococ/oraclejdk:1.8.192-alpine "bash"
docker run -it --rm --name java-1.8.192-centos registry.cn-hangzhou.aliyuncs.com/rancococ/oraclejdk:1.8.192-centos "bash"
