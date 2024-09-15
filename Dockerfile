# 使用官方 Rust 镜像作为基础镜像进行构建
FROM rust:latest as builder

# 安装必要依赖
RUN apt-get update && apt-get install -y protobuf-compiler

# 设置工作目录
WORKDIR /usr/src/majsoulmax

# 将项目的 Cargo.toml 和 Cargo.lock 复制到容器中
COPY Cargo.toml Cargo.lock ./

# 将项目所有文件复制到容器中
COPY . .

# 将配置文件复制到容器
RUN mkdir /usr/src/majsoulmax/liqi_config
COPY /proto/* /usr/src/majsoulmax/liqi_config/
COPY /liqi_config/* /usr/src/majsoulmax/liqi_config/

# 预先下载依赖并编译项目
RUN cargo build --release --verbose

# 使用 Ubuntu 22.04 或 Debian Sid 镜像作为部署基础
FROM ubuntu:22.04

# 设置工作目录
WORKDIR /usr/src/majsoulmax

# 安装必要的运行时库
RUN apt-get update && apt-get install -y libprotobuf-dev

# 将构建阶段生成的二进制文件复制到最终镜像中
COPY --from=builder /usr/src/majsoulmax/target/release/majsoul_max_rs .

# 设置环境变量
ENV ROCKET_ADDRESS=0.0.0.0

# 暴露端口
EXPOSE 23410

# 设置启动命令，运行二进制文件
CMD ["./majsoul_max_rs"]
