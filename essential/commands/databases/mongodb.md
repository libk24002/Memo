## MongoDB 命令速查

> MongoDB 是最流行的 NoSQL 文档数据库。作为运维人员，掌握 MongoDB 命令对于数据库管理、备份恢复、性能优化至关重要。

---

## 连接与基础操作

### 连接数据库

```bash
# 连接本地 MongoDB
mongo
mongosh  # MongoDB 5.0+ 使用新 shell

# 连接远程 MongoDB
mongo host:port/database
mongo "mongodb://username:password@host:port/database"

# 连接副本集
mongo "mongodb://host1:port1,host2:port2/database?replicaSet=rs0"

# 连接分片集群
mongo "mongodb://mongos-host:port/database"

# 使用认证连接
mongo -u username -p password --authenticationDatabase admin
```

### 数据库操作

```javascript
// 查看所有数据库
show dbs
show databases

// 切换/创建数据库
use mydb

// 查看当前数据库
db
db.getName()

// 查看数据库状态
db.stats()

// 删除当前数据库
db.dropDatabase()

// 查看所有集合
show collections
show tables

// 创建集合
db.createCollection("users")
db.createCollection("users", {capped: true, size: 10000, max: 100})

// 删除集合
db.users.drop()
```

---

## CRUD 操作

### 插入文档（Create）

```javascript
// 插入单个文档
db.users.insertOne({
    name: "张三",
    age: 25,
    email: "zhangsan@example.com",
    createdAt: new Date()
})

// 插入多个文档
db.users.insertMany([
    {name: "李四", age: 30, email: "lisi@example.com"},
    {name: "王五", age: 28, email: "wangwu@example.com"}
])

// 插入并返回结果
db.users.insert({name: "赵六", age: 35})
```

### 查询文档（Read）

```javascript
// 查询所有文档
db.users.find()
db.users.find().pretty()  // 格式化输出

// 查询单个文档
db.users.findOne()
db.users.findOne({name: "张三"})

// 条件查询
db.users.find({age: 25})
db.users.find({age: {$gt: 25}})  // 年龄大于25
db.users.find({age: {$gte: 25}})  // 年龄大于等于25
db.users.find({age: {$lt: 30}})  // 年龄小于30
db.users.find({age: {$lte: 30}})  // 年龄小于等于30
db.users.find({age: {$ne: 25}})  // 年龄不等于25

// 多条件查询（AND）
db.users.find({age: {$gt: 25}, name: "张三"})

// 或查询（OR）
db.users.find({$or: [{age: 25}, {age: 30}]})

// 范围查询
db.users.find({age: {$in: [25, 30, 35]}})
db.users.find({age: {$nin: [25, 30]}})

// 正则表达式查询
db.users.find({name: /张/})
db.users.find({name: {$regex: "张"}})

// 字段投影
db.users.find({}, {name: 1, age: 1, _id: 0})

// 排序
db.users.find().sort({age: 1})  // 升序
db.users.find().sort({age: -1})  // 降序

// 限制数量
db.users.find().limit(10)

// 跳过
db.users.find().skip(10)

// 分页
db.users.find().skip(10).limit(10)

// 统计数量
db.users.count()
db.users.countDocuments({age: {$gt: 25}})
```

### 更新文档（Update）

```javascript
// 更新单个文档
db.users.updateOne(
    {name: "张三"},
    {$set: {age: 26}}
)

// 更新多个文档
db.users.updateMany(
    {age: {$lt: 30}},
    {$set: {status: "young"}}
)

// 替换文档
db.users.replaceOne(
    {name: "张三"},
    {name: "张三", age: 27, email: "new@example.com"}
)

// 更新操作符
db.users.updateOne({name: "张三"}, {$inc: {age: 1}})  // 增加
db.users.updateOne({name: "张三"}, {$mul: {age: 2}})  // 乘法
db.users.updateOne({name: "张三"}, {$unset: {email: ""}})  // 删除字段
db.users.updateOne({name: "张三"}, {$rename: {email: "mail"}})  // 重命名字段

// 数组操作
db.users.updateOne({name: "张三"}, {$push: {tags: "new"}})  // 添加到数组
db.users.updateOne({name: "张三"}, {$pull: {tags: "old"}})  // 从数组删除
db.users.updateOne({name: "张三"}, {$addToSet: {tags: "unique"}})  // 添加唯一值

// upsert（不存在则插入）
db.users.updateOne(
    {name: "新用户"},
    {$set: {age: 20}},
    {upsert: true}
)
```

### 删除文档（Delete）

```javascript
// 删除单个文档
db.users.deleteOne({name: "张三"})

// 删除多个文档
db.users.deleteMany({age: {$lt: 20}})

// 删除所有文档
db.users.deleteMany({})
```

---

## 索引管理

### 创建索引

```javascript
// 创建单字段索引
db.users.createIndex({name: 1})  // 升序
db.users.createIndex({age: -1})  // 降序

// 创建复合索引
db.users.createIndex({name: 1, age: -1})

// 创建唯一索引
db.users.createIndex({email: 1}, {unique: true})

// 创建稀疏索引（只索引包含该字段的文档）
db.users.createIndex({email: 1}, {sparse: true})

// 创建 TTL 索引（自动过期）
db.logs.createIndex({createdAt: 1}, {expireAfterSeconds: 86400})

// 创建文本索引
db.articles.createIndex({content: "text"})

// 创建地理空间索引
db.places.createIndex({location: "2dsphere"})
```

### 查看和管理索引

```javascript
// 查看所有索引
db.users.getIndexes()

// 查看索引大小
db.users.totalIndexSize()

// 删除索引
db.users.dropIndex("name_1")
db.users.dropIndex({name: 1})

// 删除所有索引（除了 _id）
db.users.dropIndexes()

// 重建索引
db.users.reIndex()
```

### 索引分析

```javascript
// 分析查询执行计划
db.users.find({name: "张三"}).explain("executionStats")

// 查看慢查询
db.system.profile.find().pretty()

// 开启慢查询日志
db.setProfilingLevel(1, {slowms: 100})  // 记录超过100ms的查询
db.setProfilingLevel(2)  // 记录所有查询
db.setProfilingLevel(0)  // 关闭
```

---

## 聚合查询

### 聚合管道

```javascript
// 基本聚合
db.orders.aggregate([
    {$match: {status: "completed"}},
    {$group: {
        _id: "$customerId",
        total: {$sum: "$amount"},
        count: {$sum: 1}
    }},
    {$sort: {total: -1}},
    {$limit: 10}
])

// 常用聚合操作符
// $match: 过滤文档
{$match: {age: {$gt: 25}}}

// $group: 分组聚合
{$group: {
    _id: "$category",
    total: {$sum: "$amount"},
    avg: {$avg: "$amount"},
    max: {$max: "$amount"},
    min: {$min: "$amount"},
    count: {$sum: 1}
}}

// $project: 字段投影
{$project: {name: 1, age: 1, year: {$year: "$createdAt"}}}

// $sort: 排序
{$sort: {amount: -1}}

// $limit: 限制
{$limit: 10}

// $skip: 跳过
{$skip: 20}

// $unwind: 展开数组
{$unwind: "$tags"}

// $lookup: 关联查询（类似 JOIN）
{$lookup: {
    from: "orders",
    localField: "_id",
    foreignField: "userId",
    as: "userOrders"
}}
```

### MapReduce

```javascript
db.orders.mapReduce(
    function() { emit(this.customerId, this.amount); },
    function(key, values) { return Array.sum(values); },
    { out: "order_totals" }
)
```

---

## 用户与权限管理

### 用户管理

```javascript
// 创建管理员用户
use admin
db.createUser({
    user: "admin",
    pwd: "password",
    roles: [{role: "root", db: "admin"}]
})

// 创建普通用户
use mydb
db.createUser({
    user: "myuser",
    pwd: "password",
    roles: [
        {role: "readWrite", db: "mydb"},
        {role: "read", db: "logs"}
    ]
})

// 查看所有用户
db.getUsers()
show users

// 修改用户密码
db.changeUserPassword("myuser", "newpassword")

// 授予角色
db.grantRolesToUser("myuser", [
    {role: "readWrite", db: "newdb"}
])

// 撤销角色
db.revokeRolesFromUser("myuser", [
    {role: "read", db: "logs"}
])

// 删除用户
db.dropUser("myuser")
```

### 内置角色

```javascript
// 数据库用户角色
// - read: 只读
// - readWrite: 读写

// 数据库管理角色
// - dbAdmin: 数据库管理
// - dbOwner: 数据库所有者
// - userAdmin: 用户管理

// 集群管理角色
// - clusterAdmin: 集群管理
// - clusterManager: 集群管理器
// - clusterMonitor: 集群监控
// - hostManager: 主机管理

// 备份恢复角色
// - backup: 备份
// - restore: 恢复

// 超级管理员角色
// - root: 超级管理员
```

---

## 副本集管理

### 副本集配置

```javascript
// 初始化副本集
rs.initiate()

// 查看副本集状态
rs.status()
rs.conf()

// 添加成员
rs.add("host:port")
rs.add({host: "host:port", priority: 0, votes: 0})

// 删除成员
rs.remove("host:port")

// 设置优先级
cfg = rs.conf()
cfg.members[1].priority = 2
rs.reconfig(cfg)

// 查看主节点
rs.isMaster()
db.isMaster()

// 强制选举
rs.stepDown()

// 查看复制延迟
rs.printReplicationInfo()
rs.printSlaveReplicationInfo()
```

---

## 分片集群

### 分片配置

```javascript
// 启用分片
sh.enableSharding("mydb")

// 对集合分片
sh.shardCollection("mydb.users", {_id: "hashed"})
sh.shardCollection("mydb.orders", {customerId: 1})

// 查看分片状态
sh.status()

// 查看分片分布
db.users.getShardDistribution()

// 添加分片
sh.addShard("rs0/host1:port,host2:port")

// 删除分片
sh.removeShard("rs0")

// 平衡器管理
sh.startBalancer()
sh.stopBalancer()
sh.getBalancerState()
sh.isBalancerRunning()
```

---

## 备份与恢复

### mongodump 备份

```bash
# 备份所有数据库
mongodump --out /backup

# 备份指定数据库
mongodump --db mydb --out /backup

# 备份指定集合
mongodump --db mydb --collection users --out /backup

# 压缩备份
mongodump --db mydb --gzip --out /backup

# 远程备份
mongodump --host host:port --username admin --password pass --authenticationDatabase admin --out /backup

# 备份指定查询条件的数据
mongodump --db mydb --collection users --query '{"age":{"$gt":25}}' --out /backup
```

### mongorestore 恢复

```bash
# 恢复所有数据库
mongorestore /backup

# 恢复指定数据库
mongorestore --db mydb /backup/mydb

# 恢复指定集合
mongorestore --db mydb --collection users /backup/mydb/users.bson

# 恢复压缩备份
mongorestore --gzip /backup

# 删除后恢复（先删除再导入）
mongorestore --drop /backup

# 远程恢复
mongorestore --host host:port --username admin --password pass --authenticationDatabase admin /backup
```

### 导出导入（JSON/CSV）

```bash
# 导出 JSON
mongoexport --db mydb --collection users --out users.json
mongoexport --db mydb --collection users --type=csv --fields name,age,email --out users.csv

# 导入 JSON
mongoimport --db mydb --collection users --file users.json
mongoimport --db mydb --collection users --type=csv --headerline --file users.csv

# 导入时删除已存在数据
mongoimport --db mydb --collection users --drop --file users.json
```

---

## 性能优化

### 查询优化

```javascript
// 使用 explain 分析查询
db.users.find({age: 25}).explain("executionStats")

// 查看查询计划
db.users.find({age: 25}).explain("queryPlanner")

// 创建合适的索引
db.users.createIndex({age: 1})

// 使用投影减少数据传输
db.users.find({age: 25}, {name: 1, email: 1, _id: 0})

// 批量操作
db.users.bulkWrite([
    {insertOne: {document: {name: "user1"}}},
    {updateOne: {filter: {name: "user2"}, update: {$set: {age: 30}}}},
    {deleteOne: {filter: {name: "user3"}}}
])
```

### 监控与诊断

```javascript
// 查看数据库状态
db.serverStatus()

// 查看当前操作
db.currentOp()

// 杀死长时间运行的操作
db.killOp(opid)

// 查看连接数
db.serverStatus().connections

// 查看锁状态
db.serverStatus().locks

// 查看慢查询
db.system.profile.find({millis: {$gt: 100}}).sort({ts: -1})
```

---

## 常用配置

### mongod.conf 配置文件

```yaml
# 网络配置
net:
  port: 27017
  bindIp: 0.0.0.0

# 存储配置
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true
  engine: wiredTiger
  wiredTiger:
    engineConfig:
      cacheSizeGB: 2

# 日志配置
systemLog:
  destination: file
  path: /var/log/mongodb/mongod.log
  logAppend: true

# 安全配置
security:
  authorization: enabled

# 副本集配置
replication:
  replSetName: rs0

# 分片配置
sharding:
  clusterRole: shardsvr
```

---

## 故障排查

### 常见问题

```bash
# 查看 MongoDB 日志
tail -f /var/log/mongodb/mongod.log

# 检查磁盘空间
df -h

# 检查 MongoDB 进程
ps aux | grep mongod

# 检查端口占用
netstat -tlnp | grep 27017
ss -tlnp | grep 27017

# 修复数据库
mongod --repair --dbpath /var/lib/mongodb

# 检查数据完整性
db.runCommand({validate: "users", full: true})
```

### 性能问题排查

```javascript
// 查看慢查询
db.system.profile.find({millis: {$gt: 100}}).limit(10).sort({ts: -1})

// 查看索引使用情况
db.users.aggregate([{$indexStats: {}}])

// 查看集合统计
db.users.stats()

// 查看数据库统计
db.stats()
```

---

## 实用脚本

### 批量插入脚本

```javascript
// 批量插入测试数据
for(let i = 0; i < 10000; i++) {
    db.users.insert({
        name: "user" + i,
        age: Math.floor(Math.random() * 50) + 18,
        email: "user" + i + "@example.com",
        createdAt: new Date()
    })
}
```

### 数据清理脚本

```javascript
// 删除30天前的日志
db.logs.deleteMany({
    createdAt: {$lt: new Date(Date.now() - 30*24*60*60*1000)}
})
```

### 监控脚本

```bash
#!/bin/bash
# MongoDB 连接数监控

CURRENT=$(mongo --quiet --eval "db.serverStatus().connections.current")
AVAILABLE=$(mongo --quiet --eval "db.serverStatus().connections.available")
USAGE=$(echo "scale=2; $CURRENT/($CURRENT+$AVAILABLE)*100" | bc)

echo "当前连接数: $CURRENT"
echo "可用连接数: $AVAILABLE"
echo "使用率: ${USAGE}%"

if (( $(echo "$USAGE > 80" | bc -l) )); then
    echo "警告: 连接数使用率超过 80%"
fi
```

---

## 最佳实践

### 索引设计
- ✅ 为经常查询的字段创建索引
- ✅ 使用复合索引覆盖多字段查询
- ✅ 避免创建过多索引（影响写入性能）
- ✅ 定期分析和优化索引

### 数据建模
- ✅ 合理使用嵌入文档和引用
- ✅ 避免过深的嵌套
- ✅ 考虑查询模式设计数据结构

### 安全加固
- ✅ 启用认证
- ✅ 使用强密码
- ✅ 限制网络访问
- ✅ 定期备份数据
- ✅ 启用审计日志

### 性能优化
- ✅ 合理配置缓存大小
- ✅ 使用投影减少数据传输
- ✅ 批量操���提高效率
- ✅ 监控慢查询
- ✅ 合理分片
