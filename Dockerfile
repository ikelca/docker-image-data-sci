FROM centos

LABEL version="1.0" \
      name="CentOS Base Image" \
      vendor="CentOS" \
      license="GPLv2" \
      build-date="20190308"
USER root
RUN echo "root:m" | chpasswd

EXPOSE 1-60000
RUN yum -y update;yum clean all
RUN yum -y install wget yum-plugin-ovl centos-release-scl; yum clean all

RUN yum -y install gcc openssl-devel bzip2-devel python-devel libffi-devel;yum clean all

RUN yum install -y wget openssh-server openssh-clients which findspark lsof telnet net-tools psmisc passwd openssl-devel bzip2-devel java-1.8.0-openjdk-devel rh-python36 nano;yum clean all 


RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python2 get-pip.py 

RUN pip --no-cache-dir install jupyter Theano Keras SciKit-Learn pandas Bokeh Seaborn NLTK Scrapy tensorflow XGBoost LightGBM CatBoost Dist-keras  
RUN ipython kernel install --prefix /tmp
  

ENV SPARK_APPLICATION_ARGS ""
ENV JAVA_HOME=/etc/alternatives/java_sdk_openjdk

ENV HADOOP_PREFIX=/opt/hadoop
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_COMMON_HOME=/opt/hadoop
ENV HADOOP_HDFS_HOME=/opt/hadoop
ENV HADOOP_MAPRED_HOME=/opt/hadoop
ENV HADOOP_YARN_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
ENV YARN_CONF_DIR=$HADOOP_PREFIX/etc/hadoop  
ENV HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"
ENV HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
ENV PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
ENV container docker
ENV PATH=$PATH:$JAVA_HOME/bin
ENV CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar


ENV PATH=/opt/rh/rh-python36/root/usr/bin${PATH:+:${PATH}}
ENV LD_LIBRARY_PATH=/opt/rh/rh-python36/root/usr/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
ENV MANPATH=/opt/rh/rh-python36/root/usr/share/man:$MANPATH
ENV PKG_CONFIG_PATH=/opt/rh/rh-python36/root/usr/lib64/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}
ENV XDG_DATA_DIRS="/opt/rh/rh-python36/root/usr/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
ENV PATH=/opt/rh/rh-python36/root/usr/bin${PATH:+:${PATH}}
ENV LD_LIBRARY_PATH=/opt/rh/rh-python36/root/usr/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
ENV MANPATH=/opt/rh/rh-python36/root/usr/share/man:$MANPATH
ENV PKG_CONFIG_PATH=/opt/rh/rh-python36/root/usr/lib64/pkgconfig${PKG_CONFIG_PATH:+:${PKG_CONFIG_PATH}}
ENV XDG_DATA_DIRS="/opt/rh/rh-python36/root/usr/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

RUN python get-pip.py

RUN wget http://www-us.apache.org/dist/hadoop/common/hadoop-2.9.2/hadoop-2.9.2.tar.gz
RUN tar -zxvf /hadoop-2.9.2.tar.gz -C /opt
RUN mv /opt/hadoop-2.9.2 /opt/hadoop \
    && rm hadoop-2.9.2.tar.gz
COPY hadoop-env.sh /opt/hadoop/etc/hadoop/hadoop-env.sh
COPY core-site.xml /opt/hadoop/etc/hadoop/core-site.xml
COPY hdfs-site.xml /opt/hadoop/etc/hadoop/hdfs-site.xml
COPY yarn-site.xml /opt/hadoop/etc/hadoop/yarn-site.xml 
  

RUN /opt/hadoop/bin/hdfs namenode -format

RUN /opt/rh/rh-python36/root/bin/pip3 install --no-cache-dir pyspark
  
RUN /opt/rh/rh-python36/root/bin/pip3 install --upgrade --no-cache-dir pip
RUN /opt/rh/rh-python36/root/bin/pip3 install --no-cache-dir torch torchvision
RUN /opt/rh/rh-python36/root/bin/pip3 install --no-cache-dir ipython ipykernel Theano Keras SciKit-Learn pandas Bokeh Seaborn NLTK Scrapy tensorflow XGBoost LightGBM CatBoost Dist-keras  

RUN /opt/rh/rh-python36/root/usr/bin/ipython kernel install --prefix /tmp \
    && jupyter kernelspec install /tmp/share/jupyter/kernels/python3

RUN pip2 uninstall jupyter -y && rm get-pip.py

RUN /usr/sbin/sshd-keygen -A \
    && echo yes | ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
    && chmod 0600 ~/.ssh/authorized_keys \
    && /bin/bash -c /usr/sbin/sshd -4 \ 
    && echo StrictHostKeyChecking no >> /etc/ssh/ssh_config

RUN wget https://www.scala-lang.org/files/archive/scala-2.12.7.tgz \
     && tar xvf scala-2.12.7.tgz \
     && mv scala-2.12.7 /usr/lib \
     && ln -s /usr/lib/scala-2.12.7 /usr/lib/scala \
     && rm scala-2.12.7.tgz
ENV PATH=$PATH:/usr/lib/scala/bin

RUN scala -version
RUN pip install spylon-kernel && python -m spylon_kernel install


RUN wget http://apache.mirror.vexxhost.com/spark/spark-2.4.1/spark-2.4.1-bin-hadoop2.7.tgz \
    && tar xvf spark-2.4.1-bin-hadoop2.7.tgz \
    && mv spark-2.4.1-bin-hadoop2.7 /opt/spark \
    && rm spark-2.4.1-bin-hadoop2.7.tgz
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin

RUN /opt/rh/rh-python36/root/bin/pip3 install --no-cache-dir SpaCy turicreate

#CMD ["/usr/sbin/init"]
RUN mkdir workplace   
ENTRYPOINT /usr/sbin/sshd && cd workplace && start-all.sh && jupyter notebook --no-browser --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --allow-root --ip=0.0.0.0 

