## SQL 命令速查

> 作为运维人员，数据库是核心基础设施之一。掌握 SQL 命令对于数据库管理、故障排查、性能优化至关重要。

---

## MySQL 命令

### 连接与基础操作

```bash
# 连接数据库
mysql -h hostname -u username -p
mysql -h localhost -u root -p

# 指定数据库连接
mysql -h hostname -u username -p database_name

# 查看所有数据库
SHOW DATABASES;

# 切换数据库
USE database_name;

# 查看当前数据库所有表
SHOW TABLES;

# 查看表结构
DESC table_name;
SHOW CREATE TABLE table_name;

# 查看表索引
SHOW INDEX FROM table_name;
```

---

## 用户与权限管理

### 用户操作

```sql
-- 创建用户
CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';
CREATE USER 'username'@'%' IDENTIFIED BY 'password';  -- 允许任意主机连接

-- 删除用户
DROP USER 'username'@'localhost';

-- 修改用户密码
ALTER USER 'username'@'localhost' IDENTIFIED BY 'new_password';
-- 或使用（MySQL 5.7 之前）
SET PASSWORD FOR 'username'@'localhost' = PASSWORD('new_password');

-- 查看所有用户
SELECT user, host FROM mysql.user;
```

### 权限管理

```sql
-- 授予所有权限
GRANT ALL PRIVILEGES ON database_name.* TO 'username'@'localhost';

-- 授予特定权限
GRANT SELECT, INSERT, UPDATE, DELETE ON database_name.table_name TO 'username'@'localhost';

-- 授予远程访问权限
GRANT ALL PRIVILEGES ON *.* TO 'username'@'%' IDENTIFIED BY 'password';

-- 查看用户权限
SHOW GRANTS FOR 'username'@'localhost';

-- 撤销权限
REVOKE ALL PRIVILEGES ON database_name.* FROM 'username'@'localhost';

-- 刷新权限（立即生效）
FLUSH PRIVILEGES;
```

---

## 数据库备份与恢复

### 备份（mysqldump）

```bash
# 备份单个数据库
mysqldump -h hostname -u username -p database_name > backup.sql

# 备份多个数据库
mysqldump -h hostname -u username -p --databases db1 db2 db3 > backup.sql

# 备份所有数据库
mysqldump -h hostname -u username -p --all-databases > all_backup.sql

# 备份单个表
mysqldump -h hostname -u username -p database_name table_name > table_backup.sql

# 备份数据库结构（不包含数据）
mysqldump -h hostname -u username -p --no-data database_name > structure.sql

# 备份数据（不包含结构）
mysqldump -h hostname -u username -p --no-create-info database_name > data.sql

# 压缩备份
mysqldump -h hostname -u username -p database_name | gzip > backup.sql.gz

# 带时间戳的自动备份脚本
mysqldump -h localhost -u root -pPASSWORD database_name > backup_$(date +%Y%m%d_%H%M%S).sql
```

### 恢复数据库

```bash
# 恢复数据库
mysql -h hostname -u username -p database_name < backup.sql

# 恢复压缩备份
gunzip < backup.sql.gz | mysql -h hostname -u username -p database_name

# 直接恢复所有数据库
mysql -h hostname -u username -p < all_backup.sql
```

---

## 性能优化

### 慢查询分析

```sql
-- 开启慢查询日志
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 2;  -- 超过2秒的查询记录
SET GLOBAL slow_query_log_file = '/var/log/mysql/slow.log';

-- 查看慢查询配置
SHOW VARIABLES LIKE 'slow_query%';
SHOW VARIABLES LIKE 'long_query_time';

-- 查询执行计划（分析查询性能）
EXPLAIN SELECT * FROM table_name WHERE condition;
EXPLAIN EXTENDED SELECT * FROM table_name WHERE condition;
```

### 索引管理

```sql
-- 创建索引
CREATE INDEX index_name ON table_name(column_name);
CREATE UNIQUE INDEX index_name ON table_name(column_name);
CREATE INDEX index_name ON table_name(col1, col2);  -- 复合索引

-- 查看索引
SHOW INDEX FROM table_name;

-- 删除索引
DROP INDEX index_name ON table_name;

-- 分析表（优化索引）
ANALYZE TABLE table_name;

-- 优化表（整理碎片）
OPTIMIZE TABLE table_name;
```

### 查询优化

```sql
-- 查看表状态
SHOW TABLE STATUS FROM database_name LIKE 'table_name';

-- 查看进程列表（当前执行的查询）
SHOW PROCESSLIST;
SHOW FULL PROCESSLIST;

-- 杀死慢查询进程
KILL process_id;

-- 查看数据库状态
SHOW STATUS;
SHOW STATUS LIKE 'Threads%';
SHOW STATUS LIKE 'Connections';

-- 查看数据库变量
SHOW VARIABLES;
SHOW VARIABLES LIKE 'max_connections';
```

---

## 表操作

### 创建与修改表

```sql
-- 创建表
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_username (username)
);

-- 修改表结构
ALTER TABLE table_name ADD COLUMN column_name VARCHAR(100);
ALTER TABLE table_name DROP COLUMN column_name;
ALTER TABLE table_name MODIFY COLUMN column_name VARCHAR(200);
ALTER TABLE table_name CHANGE old_name new_name VARCHAR(100);

-- 重命名表
RENAME TABLE old_table TO new_table;

-- 清空表数据
TRUNCATE TABLE table_name;  -- 速度快，不记录日志
DELETE FROM table_name;      -- 速度慢，可回滚

-- 删除表
DROP TABLE table_name;
DROP TABLE IF EXISTS table_name;
```

---

## 事务处理

```sql
-- 开启事务
START TRANSACTION;
-- 或
BEGIN;

-- 提交事务
COMMIT;

-- 回滚事务
ROLLBACK;

-- 保存点
SAVEPOINT savepoint_name;
ROLLBACK TO SAVEPOINT savepoint_name;

-- 查看事务隔离级别
SHOW VARIABLES LIKE 'transaction_isolation';

-- 设置事务隔离级别
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

---

## 锁管理

```sql
-- 表锁
LOCK TABLES table_name READ;   -- 读锁
LOCK TABLES table_name WRITE;  -- 写锁
UNLOCK TABLES;

-- 查看锁信息
SHOW OPEN TABLES WHERE In_use > 0;

-- 查看 InnoDB 锁等待
SELECT * FROM information_schema.INNODB_LOCKS;
SELECT * FROM information_schema.INNODB_LOCK_WAITS;
```

---

## 主从复制

### 主库配置

```sql
-- 查看主库状态
SHOW MASTER STATUS;

-- 创建复制用户
CREATE USER 'repl'@'%' IDENTIFIED BY 'password';
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
```

### 从库配置

```sql
-- 配置主库信息
CHANGE MASTER TO
  MASTER_HOST='master_host',
  MASTER_USER='repl',
  MASTER_PASSWORD='password',
  MASTER_LOG_FILE='mysql-bin.000001',
  MASTER_LOG_POS=154;

-- 启动从库复制
START SLAVE;

-- 查看从库状态
SHOW SLAVE STATUS\G

-- 停止从库复制
STOP SLAVE;

-- 重置从库
RESET SLAVE;
```

---

## PostgreSQL 常用命令

### 连接与基础操作

```bash
# 连接数据库
psql -h hostname -U username -d database_name

# 切换数据库
\c database_name

# 列出所有数据库
\l

# 列出所有表
\dt

# 查看表结构
\d table_name

# 列出所有用户
\du

# 退出
\q
```

### 用户与权限

```sql
-- 创建用户
CREATE USER username WITH PASSWORD 'password';

-- 创建数据库
CREATE DATABASE database_name OWNER username;

-- 授权
GRANT ALL PRIVILEGES ON DATABASE database_name TO username;
GRANT SELECT, INSERT, UPDATE ON table_name TO username;

-- 撤销权限
REVOKE ALL PRIVILEGES ON DATABASE database_name FROM username;
```

### 备份与恢复

```bash
# 备份数据库
pg_dump -h hostname -U username database_name > backup.sql
pg_dump -h hostname -U username -Fc database_name > backup.dump  # 自定义格式

# 备份所有数据库
pg_dumpall -h hostname -U username > all_backup.sql

# 恢复数据库
psql -h hostname -U username -d database_name < backup.sql
pg_restore -h hostname -U username -d database_name backup.dump
```

---

## 运维技巧

### 日常巡检

```sql
-- 查看数据库大小
SELECT
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.TABLES
GROUP BY table_schema;

-- 查看表大小
SELECT
    table_name AS 'Table',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE table_schema = 'database_name'
ORDER BY (data_length + index_length) DESC;

-- 查看连接数
SHOW STATUS LIKE 'Threads_connected';
SHOW VARIABLES LIKE 'max_connections';

-- 查看缓存命中率
SHOW STATUS LIKE 'Qcache%';
```

### 性能监控

```sql
-- 查看 InnoDB 状态
SHOW ENGINE INNODB STATUS\G

-- 查看最耗资源的查询
SELECT * FROM sys.statement_analysis LIMIT 10;

-- 查看未使用的索引
SELECT * FROM sys.schema_unused_indexes;
```

### 故障排查

```bash
# 查看错误日志
tail -f /var/log/mysql/error.log

# 查看慢查询日志
tail -f /var/log/mysql/slow.log

# 分析慢查询日志
mysqldumpslow -s t -t 10 /var/log/mysql/slow.log  # 显示最慢的10条
```

---

## 安全加固

```sql
-- 删除匿名用户
DELETE FROM mysql.user WHERE User='';

-- 删除 test 数据库
DROP DATABASE IF EXISTS test;

-- 禁止 root 远程登录
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- 刷新权限
FLUSH PRIVILEGES;
```

---

## 常用配置优化

```ini
# /etc/my.cnf 或 /etc/mysql/my.cnf

[mysqld]
# 连接数
max_connections = 500

# 缓冲池大小（建议设置为物理内存的 70-80%）
innodb_buffer_pool_size = 4G

# 慢查询日志
slow_query_log = 1
long_query_time = 2
slow_query_log_file = /var/log/mysql/slow.log

# 二进制日志
log_bin = /var/log/mysql/mysql-bin.log
expire_logs_days = 7
max_binlog_size = 100M

# 字符集
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
```

---

## 实用脚本

### 自动备份脚本

```bash
#!/bin/bash
# MySQL 自动备份脚本

BACKUP_DIR="/backup/mysql"
DATE=$(date +%Y%m%d_%H%M%S)
DB_USER="root"
DB_PASS="password"
DB_NAME="database_name"

mkdir -p $BACKUP_DIR

# 备份数据库
mysqldump -u$DB_USER -p$DB_PASS $DB_NAME | gzip > $BACKUP_DIR/${DB_NAME}_${DATE}.sql.gz

# 删除7天前的备份
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

echo "Backup completed: ${DB_NAME}_${DATE}.sql.gz"
```

### 监控脚本

```bash
#!/bin/bash
# MySQL 连接数监控

MAX_CONN=$(mysql -uroot -ppassword -e "SHOW VARIABLES LIKE 'max_connections';" | awk 'NR==2{print $2}')
CURR_CONN=$(mysql -uroot -ppassword -e "SHOW STATUS LIKE 'Threads_connected';" | awk 'NR==2{print $2}')
USAGE=$(echo "scale=2; $CURR_CONN/$MAX_CONN*100" | bc)

echo "当前连接数: $CURR_CONN / $MAX_CONN (使用率: ${USAGE}%)"

if (( $(echo "$USAGE > 80" | bc -l) )); then
    echo "警告: 连接数使用率超过 80%"
fi
```
