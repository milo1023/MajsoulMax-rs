# 使用官方 Rust 镜像作为基础镜像进行构建
FROM rust:latest

# 设置工作目录
WORKDIR /usr/src/majsoulmax

# 将项目的 Cargo.toml 和 Cargo.lock 复制到容器中
COPY Cargo.toml Cargo.lock ./

# 预先下载依赖
RUN cargo fetch

# 将项目所有文件复制到容器中
COPY . .

# 编译项目，使用 --release 生成优化后的二进制文件
RUN cargo build --release

# 使用一个更小的基础镜像来部署最终的二进制文件
FROM debian:buster-slim

# 设置工作目录
WORKDIR /usr/src/majsoulmax

# 将构建阶段生成的二进制文件复制到最终镜像中
COPY --from=builder /usr/src/majsoulmax/target/release/majsoul_max_rs .

# 设置环境变量，避免 Docker 容器生成过多缓存
ENV ROCKET_ADDRESS=0.0.0.0

# 将容器的 8000 端口暴露给外界访问
EXPOSE 23410

# 设置启动命令，运行二进制文件
CMD ["./majsoul_max_rs"]
