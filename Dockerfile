# 使用官方Ubuntu 24.04作为基础镜像
FROM ubuntu:24.04

# 设置环境变量避免交互式安装提示
ENV DEBIAN_FRONTEND=noninteractive

# 安装基础工具和依赖
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    ca-certificates \
    # 安装解压工具
    tar \
    # 安装MongoDB需要的工具
    gpg \
    # 安装网络工具（用于健康检查）
    curl \
    && rm -rf /var/lib/apt/lists/*

# 从指定链接下载并安装OpenJDK 25 GPL版本
RUN mkdir -p /usr/lib/jvm && \
    cd /usr/lib/jvm && \
    wget -O openjdk-25_linux-x64_bin.tar.gz \
    "https://download.java.net/java/GA/jdk25/bd75d5f9689641da8e1daabeccb5528b/36/GPL/openjdk-25_linux-x64_bin.tar.gz" && \
    tar -xzvf openjdk-25_linux-x64_bin.tar.gz && \
    rm openjdk-25_linux-x64_bin.tar.gz && \
    # 设置默认Java版本
    update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-25/bin/java 1 && \
    update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-25/bin/javac 1

# 设置JAVA_HOME环境变量
ENV JAVA_HOME /usr/lib/jvm/jdk-25
ENV PATH $JAVA_HOME/bin:$PATH

# 安装MongoDB 7.0社区版（当前最新稳定版）
RUN wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/mongodb.gpg] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list && \
    apt-get update && \
    apt-get install -y mongodb-org && \
    rm -rf /var/lib/apt/lists/*

# 创建应用目录
RUN mkdir -p /data/orcheTeam

# 将当前目录（包括子目录）所有文件复制到容器中
COPY . /data/orcheTeam/

# 确保所有脚本可执行
RUN chmod +x /data/orcheTeam/bin/*.sh

# 创建MongoDB数据目录
RUN mkdir -p /data/db

# 暴露应用端口端口
EXPOSE 7474 

# 设置工作目录
WORKDIR /data/orcheTeam

# 设置启动命令
CMD (mongod --fork --logpath /var/log/mongod.log) && \
	cd /data/orcheTeam/bin && \
	./startup.sh

# 健康检查
#HEALTHCHECK --interval=30s --timeout=5s \
#    CMD curl -f http://localhost:7474/health || exit 1
