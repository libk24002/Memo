## Dockerfile
* Dockerfile 的指令每执行一次都会在 docker 上新建一层。所以过多无意义的层，会造成镜像膨胀过大

### FROM
* ```dockerfile
  FROM docker.io/library/debian:bullseye
  RUN echo '这是一个本地构建的debian镜像' > /tmp/test.html
  ```

### RUN
* ```dockerfile
  FROM docker.io/library/debian:bullseye
  # shell
  RUN apt update
  # exec
  RUN apt install -y curl wget

  RUN curl -L https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py38_23.3.1-0-Linux-x86_64.sh -o /tmp/miniconda.sh

  RUN bash /tmp/miniconda.sh -b -p /miniconda && rm -f /tmp/miniconda.sh
  ```
* 过多无意义的层，会造成镜像膨胀过大, 下边这段是改良版
* ```dockerfile
  FROM docker.io/library/debian:bullseye

  RUN apt update && apt install -y curl wget \
      && curl -L https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py38_23.3.1-0-Linux-x86_64.sh -o /tmp/miniconda.sh \
      && bash /tmp/miniconda.sh -b -p /miniconda && rm -f /tmp/miniconda.sh
  ```

### COPY
* ```dockerfile
  FROM docker.io/library/debian:bullseye

  # COPY [--chown=<user>:<group>] <源路径1>...  <目标路径>
  COPY nginx.conf /tmp/nginx.conf
  COPY --chown=nginx:nginx nginx.conf /tmp/nginx.conf
  ```

### ADD
* ```dockerfile
  FROM docker.io/library/debian:bullseye

  ADD nginx.conf /tmp/nginx.conf
  ```

### CMD
* 仅最后一个生效
* ```dockerfile
  FROM docker.io/library/debian:bullseye

  ADD nginx.conf /tmp/nginx.conf
  # exec
  CMD ["/bin/bash", "echo", "$?"]
  ```

### ENTRYPOINT
* 仅最后一个生效
* ```dockerfile
  FROM docker.io/library/debian:bullseye

  # exec
  # ENTRYPOINT ["executable", "param1", "param2"]
  ENTRYPOINT ["top", "-b"]
  CMD ["-c"]
  ```

### ENV
* 镜像构建以及镜像构建成功后也可以使用
* ```dockerfile
  FROM docker.io/library/debian:bullseye

  # ENV <key> <value>
  # ENV <key1>=<value1> <key2>=<value2>
  ENV KEY1=key1
      KEY2=key2

  ENV key3=key3
  ENV key4=key4
  ```

### ARG
* 只能在镜像构建中使用
* ```dockerfile
  # ARG <key>=<default>
  ARG BASE_IMAGE=docker.io/library/debian:bullseye
  FROM $BASE_IMAGE
  ```

### VOLUME
* -v 参数修改挂在
* ```dockerfile
  FROM docker.io/library/debian:bullseye

  # VOLUME ["/data", "/data"]
  VOLUME ["/data"]
  ```

### EXPOSE
* 声明端口作用
* ```dockerfile
  FROM docker.io/library/debian:bullseye

  EXPOSE 22
  ```

### WORKDIR
* ```dockerfile
  FROM docker.io/library/debian:bullseye

  WORKDIR /home
  CMD ["pwd"]
  ```

### USER
* ```dockerfile
  FROM docker.io/library/debian:bullseye

  USER root
  CMD ["who"]
  ```

* LABEL
* ```dockerfile
  FROM docker.io/library/debian:bullseye

  # LABEL <key>=<value> <key>=<value> <key>=<value>
  LABEL author=libk
  ```
