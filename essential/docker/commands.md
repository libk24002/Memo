## docker commands

### Docker IPAddress
* ```shell
  docker inspect -f '{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -aq)
  ```

### Docker-registry
* ```shell
  REGISTRY_NAME="docker-registry"
  running="$(docker inspect -f '{{.State.Running}}' ${REGISTRY_NAME} 2>/dev/null || true)"
  if [ "${running}" != 'true' ]; then
      DOCKER_REGISTRY_IMAGE=registry:2.7.1
      docker inspect $DOCKER_REGISTRY_IMAGE > /dev/null 2>&1 || docker pull $DOCKER_REGISTRY_IMAGE
      docker run --restart=always \
          -p "127.0.0.1:5000:5000" \
          --name "${REGISTRY_NAME}" \
          -d $DOCKER_REGISTRY_IMAGE
  fi
  ```

### Docker-registry API
* ```shell
  GET /v2/_catalog # 列出所有存储库
  GET /V2/image/tags/list  # 列出所有image所有tag
  ?n=<inter> # 指定个数
  ```
