## Linux Memo

### jasypt 密码编译
* ```shell
  java -cp jasypt-1.9.3.jar org.jasypt.intf.cli.JasyptPBEStringEncryptionCLI input="5DdS6LgtZj" password="4tr=Kl34jDs@O/u4_#2c"
  java -cp jasypt-1.9.3.jar org.jasypt.intf.cli.JasyptPBEStringEncryptionCLI input="abc123"password=test algorithm=PBEWithMD5AndDES
  ```
  
### reposync repo 源同步
* ```shell
  reposync -p /var/www/repos/centos-stream/8/x86_64/os/ --repo=updates --download-metadata
  ```
  
### minio 备份
* ```shell
  ## MINIO备份相关
  SOURCE_MINIO_SERVER=http://api-minio-test.lab.zjvis.net:32080
  SOURCE_MINIO_SERVER_ACCESS_KEY="4bGM1NeMMh"
  SOURCE_MINIO_SERVER_SECRET_KEY="oSus3dcwX1oJfRHFrUNdjOa8WraM5qs4MXTYXWGg"
  TARGET_MINIO_SERVER=http://api-minio-dev.lab.zjvis.net:32080
  TARGET_MINIO_SERVER_ACCESS_KEY="h732egieda"
  TARGET_MINIO_SERVER_SECRET_KEY="DDWupvlNPpdrNCKsZZAUVMh4OOmj999VLUhCNSDR"
  mc config host add minio_source ${SOURCE_MINIO_SERVER} \
      ${SOURCE_MINIO_SERVER_ACCESS_KEY} ${SOURCE_MINIO_SERVER_SECRET_KEY} \
  && mc config host add minio_target ${TARGET_MINIO_SERVER} \
             ${TARGET_MINIO_SERVER_ACCESS_KEY} ${TARGET_MINIO_SERVER_SECRET_KEY} 
  for MINIO_DIR in "model-online/mo_53" \
      "model-online/mo_54"
  do
      mc diff  minio_target/${MINIO_DIR} minio_source/${MINIO_DIR} >> ./minio_diff.log
  done
  ```