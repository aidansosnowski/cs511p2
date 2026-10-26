#!/bin/bash
export JAVA_HOME=/opt/java/openjdk

####################################################################################
# DO NOT MODIFY THE BELOW ##########################################################

ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys

# DO NOT MODIFY THE ABOVE ##########################################################
####################################################################################

# Setup HDFS/Spark main here

echo 'export JAVA_HOME=/opt/java/openjdk' >> \
    "$HADOOP_HOME/etc/hadoop/hadoop-env.sh"

mkdir -p /opt/hadoop-data/namenode
mkdir -p /opt/hadoop-data/datanode


cat > "$HADOOP_HOME/etc/hadoop/core-site.xml" <<'EOF'
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://main:9000</value>
    </property>
</configuration>
EOF

cat > "$HADOOP_HOME/etc/hadoop/hdfs-site.xml" <<'EOF'
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
    <property>
        <name>dfs.replication</name>
        <value>3</value>
    </property>

    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:///opt/hadoop-data/namenode</value>
    </property>

    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///opt/hadoop-data/datanode</value>
    </property>
</configuration>
EOF






mkdir -p "$SPARK_HOME/conf"

cat > "$SPARK_HOME/conf/spark-env.sh" <<'EOF'
export JAVA_HOME=/opt/java/openjdk
export SPARK_MASTER_HOST=main
export SPARK_MASTER_PORT=7077
export SPARK_MASTER_WEBUI_PORT=8080
export SPARK_WORKER_WEBUI_PORT=8081
export SPARK_WORKER_CORES=1
export SPARK_WORKER_MEMORY=1g
EOF