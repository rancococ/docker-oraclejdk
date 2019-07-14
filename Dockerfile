# from registry.cn-hangzhou.aliyuncs.com/rancococ/centos:7-utf8
FROM registry.cn-hangzhou.aliyuncs.com/rancococ/centos:7-utf8

# maintainer
MAINTAINER "rancococ" <rancococ@qq.com>

# set arg info
ARG CENTOS_VER=7
ARG APP_HOME=/data/app
ARG JDK_HOME=/data/jdk
ARG JRE_HOME=/data/jdk/jre
ARG GOSU_URL=https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64
ARG JRE_URL=https://github.com/rancococ/serverjre/releases/download/server-jre-8/server-jre-8u192-linux-x64.tar.gz

# copy script
COPY docker-entrypoint.sh /

# install repositories and packages : curl bash passwd openssl openssh wget net-tools gettext zip unzip ncurses git subversion
RUN \rm -rf /etc/yum.repos.d/*.repo && \
    curl -s -o /etc/yum.repos.d/centos.repo http://mirrors.aliyun.com/repo/Centos-${CENTOS_VER}.repo && \
    curl -s -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-${CENTOS_VER}.repo && \
    sed -i '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/centos.repo && \
    sed -i '/mirrors.cloud.aliyuncs.com/d' /etc/yum.repos.d/centos.repo && \
    cat > /etc/yum.repos.d/wandisco-svn.repo << EOF
[WANdisco-svn]
name=WANdisco Distribution of svn
baseurl=http://opensource.wandisco.com/centos/\$releasever/svn-1.8/RPMS/\$basearch
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-WANdisco
EOF && \
    cat > /etc/yum.repos.d/wandisco-git.repo << EOF
[WANdisco-git]
name=WANdisco Distribution of git
baseurl=http://opensource.wandisco.com/centos/\$releasever/git/\$basearch
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-WANdisco
EOF && \
    yum clean all && yum makecache && \
    \rm -rf /etc/pki/rpm-gpg/* && \
    curl -s -o /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${CENTOS_VER} https://mirrors.aliyun.com/centos/RPM-GPG-KEY-CentOS-${CENTOS_VER} && \
    curl -s -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${CENTOS_VER} https://mirrors.aliyun.com/epel/RPM-GPG-KEY-EPEL-${CENTOS_VER} && \
    curl -s -o /etc/pki/rpm-gpg/RPM-GPG-KEY-WANdisco http://opensource.wandisco.com/RPM-GPG-KEY-WANdisco && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${CENTOS_VER} && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-${CENTOS_VER} && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-WANdisco && \
    sed -i 's@override_install_langs=en_US.utf8@#override_install_langs=en_US.utf8@g' "/etc/yum.conf" && \
    yum install -y passwd openssl openssh-server wget net-tools gettext zip unzip ncurses git subversion && \
    yum reinstall -y glibc-common && \
    yum clean all && \rm -rf /var/lib/{cache,log} /var/log/lastlog && \
    ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' && \
    ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
    ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key  -N '' && \
    sed -i 's/#UseDNS.*/UseDNS no/g' /etc/ssh/sshd_config && \
    sed -i '/^session\s\+required\s\+pam_loginuid.so/s/^/#/' /etc/pam.d/sshd && \
    echo "Asia/Shanghai" > /etc/timezone && \ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    mkdir -p /root/.ssh && chown root.root /root && chmod 700 /root/.ssh && echo 'admin' | passwd --stdin root && \
    mkdir -p ${APP_HOME} && mkdir -p ${JDK_HOME} && \
    groupadd -r app && useradd -r -m -g app -d ${APP_HOME} -s /bin/bash app && echo '123456' | passwd --stdin app && \
    tempuuid=$(cat /proc/sys/kernel/random/uuid) && mkdir -p /tmp/${tempuuid} && \
    wget -c -O /usr/local/bin/gosu --no-cookies --no-check-certificate "${GOSU_URL}" && chmod +x /usr/local/bin/gosu && \
    wget -c -O /tmp/${tempuuid}/myjre.tar.gz --no-cookies --no-check-certificate ${JRE_URL} && \
    tar -xzf /tmp/${tempuuid}/myjre.tar.gz --directory=${JDK_HOME} --strip-components=1 && \
    \rm -rf /tmp/${tempuuid} && \
    sed -i 's@securerandom.source=file:/dev/random@securerandom.source=file:/dev/urandom@g' "${JRE_HOME}/lib/security/java.security" && \
    sed -i 's@#crypto.policy=unlimited@crypto.policy=unlimited@g' "${JRE_HOME}/lib/security/java.security" && \
    chmod -Rf u+x ${JDK_HOME}/bin/* && \
    chmod -Rf u+x ${JRE_HOME}/bin/* && \
    chown -R app:app /data && \
    chown -R app:app /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

# user root
USER root

# set environment
ENV LANG zh_CN.UTF-8
ENV TZ "Asia/Shanghai"
ENV TERM xterm
ENV JAVA_HOME ${JDK_HOME}
ENV JDK_HOME ${JDK_HOME}
ENV JRE_HOME ${JRE_HOME}
ENV CLASSPATH .:${JDK_HOME}/lib:${JRE_HOME}/lib
ENV PATH .:${PATH}:${JDK_HOME}/bin:${JRE_HOME}/bin

# set work home
WORKDIR /data

# expose port 22
EXPOSE 22

# stop signal
STOPSIGNAL SIGTERM

# entry point
ENTRYPOINT ["/docker-entrypoint.sh"]

# default command
CMD ["java", "-version"]
