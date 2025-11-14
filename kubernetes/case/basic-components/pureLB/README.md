# purelb

## main usage
* 本文借鉴文章 => [k8s系列08-负载均衡器之PureLB ](https://tinychen.com/20220524-k8s-08-loadbalancer-purelb)
* 本文主要在k8s原生集群上部署`0.6.4`版本的`PureLB`作为k8s集群的`LoadBalancer` 主要涉及PureLB的Layer2模式和ECMP模式两种部署方案.
* 本文使用的k8s集群`centos steam 8`上基于`docker`和`kind`部署的`v1.23.3`版本. => [create.local.cluster.with.kind](/basics/kubernetes/create.local.cluster.with.kind.md)
* A LoadBalancer is a Service type that allows configuration of network components external to Kubernetes to enable network access to the specified application resources.

## conceptions
* Layer2
* ECMP
* Allocator
* LBnodeagent
* KubeProxy

## purpose
* test docker registry

## precondition
* [kind-cluster](/basics/kubernetesernetes/kind-cluster.md)

## operation
1. prepare [purelb.values.yaml](resources/purelb.values.yaml.md)
2. prepare images
    * ```shell
      DOCKER_IMAGE_PATH=/root/docker-images && mkdir -p ${DOCKER_IMAGE_PATH}
      BASE_URL="https://resource.cnconti.cc:32443/docker-images"
      for IMAGE in "docker.io_purelb_allocator_v0.6.4.dim" \
          "docker.io_purelb_lbnodeagent_v0.6.4.dim"
      do
          IMAGE_FILE=$DOCKER_IMAGE_PATH/$IMAGE
          if [ ! -f $IMAGE_FILE ]; then
              TMP_FILE=$IMAGE_FILE.tmp \
                  && curl -o "$TMP_FILE" -L "$BASE_URL/$IMAGE" \
                  && mv $TMP_FILE $IMAGE_FILE
          fi
          docker image load -i $IMAGE_FILE && rm -f $IMAGE_FILE
      done
      DOCKER_REGISTRY="localhost:5000"
      for IMAGE in "docker.io/purelb/allocator:v0.6.4" \
          "docker.io/purelb/lbnodeagent:v0.6.4"
      do
          DOCKER_TARGET_IMAGE=$DOCKER_REGISTRY/$IMAGE
          docker tag $IMAGE $DOCKER_TARGET_IMAGE \
              && docker push $DOCKER_TARGET_IMAGE \
              && docker image rm $DOCKER_TARGET_IMAGE
      done
      ```
4. install `purelb` by helm
    * ```shell
      helm install \
          --create-namespace --namespace basic-components \
          my-purelb \
          https://resource.cnconti.cc:32443/charts/other/purelb-v0.6.4.tgz \
          --values purelb.values.yaml \
          --atomic
      ```
5. prepare [purelb.layer2-ippool.servicegroups.yaml](resources/purelb.layer2-ippool.servicegroups.yaml.md)
6. create ServiceGroups `purelb-layer2-ippool`
    * ```shell
      kubectl -n basic-components apply -f purelb.layer2-ippool.servicegroups.yaml
      ```

## test
1. test `purelb`
    * prepare [purelb-test.resource.yaml](resources/purelb-test.resource.yaml.md)
    * ```shell
      kubectl -n test apply -f purelb-test.resource.yaml
      ```
2. check services
    * ```shell
      kubectl -n test get svc
      ```

## uninstall
1. delete ServiceGroups `purelb-layer2-ippool`
    * ```shell
      kubectl -n basic-components delete servicegroups purelb-layer2-ippool
      ```
2. uninstall `my-purelb`
    * ```shell
      helm -n basic-components uninstall my-purelb
      ```
