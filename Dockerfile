# 使用官方 Rust 镜像作为基础镜像进行构建
FROM rust:latest as builder

# 安装构建所需的依赖库
RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    build-essential \
    curl


# 将项目的 Cargo.toml 和 Cargo.lock 复制到容器中
COPY Cargo.toml Cargo.lock ./

# 预先下载依赖
RUN cargo fetch --verbose

# 将项目所有文件复制到容器中
COPY . .

# 编译项目，使用 --release 生成优化后的二进制文件
RUN cargo build --release --verbose

# 使用一个更小的基础镜像来部署最终的二进制文件
FROM debian:buster-slim

# 设置工作目录
WORKDIR /

# 将构建阶段生成的二进制文件复制到最终镜像中
COPY --from=builder /target/release/majsoul_max_rs .

# 设置环境变量，避免 Docker 容器生成过多缓存
ENV ROCKET_ADDRESS=0.0.0.0

# 暴露端口
EXPOSE 23410

# 设置启动命令，运行二进制文件
CMD ["./majsoul_max_rs"]
