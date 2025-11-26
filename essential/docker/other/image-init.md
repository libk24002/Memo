## docker image init

### General
* ubuntu/debian
    + ```dockerfile
      ENV TZ=Asia/Shanghai
      ENV DEBIAN_FRONTEND=noninteractive
      ```

* miniconda
    + ```dockerfile
      ENV PATH=/miniconda/bin:${PATH}
      ENV LD_LIBRARY_PATH=/miniconda/lib:${LD_LIBRARY_PATH}
      
      ## version: https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda
      RUN curl -L https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-py38_23.3.1-0-Linux-x86_64.sh -o /tmp/miniconda.sh \
          && bash /tmp/miniconda.sh -b -p /miniconda && rm -f /tmp/miniconda.sh
      ```

### Ubuntu
* ubuntu `18.04` `20.04` `22.04`
    + ```dockerfile
      ## aliyun
      RUN sed -i -E 's/(archive|security).ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list \
          && apt update && apt install -y vim curl
      
      ##  tsinghua
      RUN sed -i -E 's/(archive|security).ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list \
          && apt update && apt install -y vim curl
      
      ##  ustc
      RUN sed -i -E 's/(archive|security).ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
          && apt update && apt install -y vim curl
      ```
* ubuntu `24.04`
    + ```dockerfile
      ## aliyun
      RUN sed -i -E 's/(archive|security).ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list.d/ubuntu.sources \
          && apt update && apt install -y vim curl
      
      ##  tsinghua
      RUN sed -i -E 's/(archive|security).ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/ubuntu.sources \
          && apt update && apt install -y vim curl
      
      ##  ustc
      RUN sed -i -E 's/(archive|security).ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/ubuntu.sources \
          && apt update && apt install -y vim curl
      ```

### Debian
* debian `bullseye`
    + ```dockerfile
      ## aliyun
      RUN sed -i -E 's/(deb|security).debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list \
          && apt update && apt install -y vim curl
      
      ##  tsinghua
      RUN sed -i -E 's/(deb|security).debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list \
          && apt update && apt install -y vim curl
      
      ##  ustc
      RUN sed -i -E 's/(deb|security).debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list \
          && apt update && apt install -y vim curl
      ```
* debian `bookworm` `trixie`
    + ```dockerfile
      ## aliyun
      RUN sed -i -E 's/(deb|security).debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list.d/debian.sources \
          && apt update && apt install -y vim curl
      
      ##  tsinghua
      RUN sed -i -E 's/(deb|security).debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list.d/debian.sources \
          && apt update && apt install -y vim curl
      
      ##  ustc
      RUN sed -i -E 's/(deb|security).debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources \
          && apt update && apt install -y vim curl
      ```

### Alpine
* alpine `3.15` ~ `3.22`
    + ```dockerfile
      RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
          && apk update && apk add vim curl
      ```
