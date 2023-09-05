---
title: Redis 基础学习笔记
date: 2022-05-25 17:46:43
keywords: [Redis,教程,笔记]
tags: [Redis, Study, Notes]
toc: true
layout: post
---



# Introduction

NoSQL: 解决性能问题

解决IO压力： 

Session 问题：

1. 存储到客户端cookie -- 安全性
2. session 复制到多台服务器中 -- 数据冗余， 空间浪费
3. **缓存数据库** -- 完全存在内存中， 减少IO读操作

<!-- more -->

## What is NoSQL?

Not only SQL

非关系型数据库

以key-value模式存储

* 不遵循SQL标准
* 不支持ACID
* 远超于SQL的性能

适用场景：

* 对数据高并发的读写
* 海量数据的读写
* 对数据高可扩展性的

不适用场景：

* 需要事物支持
* 基于SQL数据化存储

操作都是原子性的

## 基本特点

单线程 + 多路IO复用

default port 6379

keep cpu work until finish

# 数据类型

```
Strings 字符串

Lists 数组

Sets 集合

Sorted Sets 有序集合

Hashes 哈希

Bitmaps 位图

Hypermaps

HyperLogLog

Geospatial Indexes
```

# keys 键操作

## Strings

二进制安全的

value 最多可以是512M

* `incr key` 对key值对应value+1 

* `decr key` 对key值对应value-1

注: 需要确认value的属性为数值

原子操作: 操作一旦开始就一定会运行到结束 不会context switch

* 一次设定多个键值对:

`mset <key1> <value1> [<key2> <value2> [<key3> <value3> [...]]]`

* 一次获取多个键值对:

`mget <key1> [<key2> [<key3> [...]]]`


`msetnx` 有任何一个失败都会全部失败

`getset <key> <new-value>` 获取原始值, 并设置一个新值

### 底层结构

`string` 底层结构为 `simple dynamic string` 简单动态字符串, 是可以修改的字符串

## List

单键多值

底层是双向链表， 对两端操作性能很高

* 添加元素到`list`的左侧/右侧

`lpush/rpush <list-name> <ele1>[ <ele2>[ <ele3>[ ...]]]`

* 从左/右删除list中元素

`lpop/rpop list-name> <ele1>[ <ele2>[ <ele3>[ ...]]]`

_list空时key不存在_

* 从list1中右侧获取一个值并加到list2左侧

`rpoplpush list1 list2 `

### List底层结构
`quicklist`： 元素较少的时候使用连续内存存储， `ziplist`

数据量变多时，使用多个`ziplist`进行链接， 构成`quicklist`

## Set 集合

### 数据结构

底层结构为`dict`， 使用`hash`表实现

## Hash 哈希

`key -> hash{}`

`Map<String, Object>`

```
设置hash
hset <field> <key> <value>

获取field中key的值
hget <field> <key>

设置field中多个键值
hmset <field> <key1> <value1>[ <key2> <value2>[ <key3> <value3>[ ...]]]

判断field中key是否存在
hexists <field> <key>

获取field中所有key
hkeys <field>

获取field中所有value
hvals <field>
```

### hash底层数据结构

`ziplist` 和 `hashtable`

当`field-value`长度较少且个数较少时， 使用`ziplist`， 否则使用`hashtable`

## Zset 有序集合

集合中的每个成员都关联的score, 元素不能重复, score可以重复

```
添加元素到zset中
zadd <zset-name> <score1> <ele1>[ <score2> <ele2>[ <score3> <ele3>[ ...]]]

zrange 

zrangebyscores 从小到大排序

zrevrangebyscores 从大到小排序

加减某个元素的score
zincrby <zset-name> <score> <ele>

获取某个分数区间的元素个数
zcount <zset-name> <begin-score-include> <end-score-include>

获取某个score区间段的元素
zrank <zset-name> <begin-index-include> <end-index-include>[ withscores]
```

### 数据结构

`SortedSet` 一方面等价于Java 的`Map<String Double>`, 可以给每个value赋予一个权重score, 另一方面他又类似于`TreeSet`, 内部的元素会按照权重score 进行排序， 可以得到每个元素的名次， 还可以通过score 的范围来获取元素的列表

`Zset`底层使用了: 

1. hash 关联元素value和权重score, 保障元素value的唯一性
2. 跳跃表, 给value排序, 根据score 范围获取元素列表

# 配置文件

## 网络相关配置

`bind 127.0.0.1 -::1`

只支持本地连接

`protected-mode yes` 保护模式

`port 6379` 默认端口号

`tcp-backlog 511`

`timeout 0` 用不超时 (秒)

`tcp-keepalive 300` 检测周期300s

## 通用设置

`daemonize yes` 后台启动

`loglevel notice/debug/verbose/warning` 设置日志级别

## SECURITY 安全设置

`requirepass` 设置密码

## LIMIT 限制

`maxclients` 设置最大连接数

`maxmemory` 设置可使用的内存大小

# Pub/Sub

一种消息通信模式

`Pub` 发布者

`Sub` 订阅者

Redis 支持任意数量的频道

![](./pubsub.png)

注意: 发布的消息没有持久化

# 新版本数据类型

## Bitmaps

Redis 提供了bitmaps这个类型, 可以实现对位的操作

1. Bitmaps本身不是数据类型, 实际上就是字符串 (key-value), 但是他可以对字符串进行位操作
2. Bitmaps单独提供了一套命令, 所以在redis中使用bitmaps和使用字符串的方法不太相同, 想象成一个以位为单位的数组, 数组的每个单元只能存储0和1, 数组的下标在bitmaps中叫做偏移量.

`bitop`

`setbit`

## HyperLogLog

### 简介

与统计相关的功能需求, 如统计网站pageview, 可以使用incr, incrby实现

但是像uniquevisitor, 独立ip数, 搜索记录等需要去重和技术的问题如何解决?

这种求集合中不重复元素个数的问题称为基数问题

1. MySQL中: distinct count计算
2. Redis中的hash, set, bitmaps等数据结构

结果精确, 但随着数据不断增加, 占用空间越来越大, 对非常大的数据集时不切实际的

hyperloglog  -> 降低精确度, 减少空间占用

### 命令

`pfadd`

成功1 失败0

`pfcount`

计算基数个数

`pfmerge k1 k2`

将两个hll结构合并一起  k1 <= k2


## Geospatial

该类型就是元素的二维坐标
/ 经纬度

```
部分命令
geoadd

geopos

geodist 计算两坐标之间的距离 默认为米

georadius 给定经纬度为中心 找出某半径中的元素
```


# 事物

事物操作相互隔离, 防止别的命令执行, 按照顺序执行

序列化

## Multi, Exec, discard

`Multi` 输入的命令会进入队列 -- 组队, 但是并没有执行

`Exec` 将队列中的命令进行执行

组队过程使用`discard`放弃组队

### Example

![](./multiexample.png)


## 事物错误处理

1. 组队阶段错误

   最终执行时都不会执行

2. 执行阶段错误

   谁有错误谁不执行

##  事物冲突

### 悲观锁

每次拿数据的时候都认为别人会修改 -- 悲观

获取数据时先上锁, 在释放之前其他事物被block

**做操作之前先上锁**

 传统的RDB使用了很多这种锁机制, 行锁, 表锁等, 读锁, 写锁等

### 乐观锁

每次拿数据认为别人不会修改, 不会上锁, 但是在更新的时候会判断在此期间别人有没有更新这个数据

适用于**多读**的类型, 提高吞吐量, **Redis 就是使用check-and-set机制实现事物的**

给数据加上version号, 修改后同时更新版本号

其他更新时检查当前版本和获取版本是否一致, 不一致则无法操作

![](./positivelock.png)

WATCH KEY

在执行multi之前, 使用watch监察key的修改状态, 如果执行前key值被改动, 命令将被取消

## Redis事物三特性

1. 单独的隔离操作

   事物中的所有命令都会序列化, 按顺序地执行, 在事物执行的过程中, 不会被其他客户端发送来的命令请求所打断

2. 没有隔离级别的概念

   队列中的命令没有提交之前都不会实际被执行, 因为事物提交前任何指令都不会被实际执行

3. 不保证原子性

   事物中如果有一条命令执行失败, 其后的命令仍然会被执行, 没有回滚

# 秒杀抢货案例

![](./miaosha.png)

1. 超卖问题

   通过乐观锁解决

2. 连接超时问题

   连接池解决

3. 库存遗留问题

   乐观锁造成, 因版本号不一致, 导致其他所有人无法购买

   解决: lua脚本 -> 有一定的原子性 -> 通过lua脚本在redis中组队

# 持久化 

## RDB Redis DataBase

在指定的**时间间隔**内将内存中的**数据集**快照Snapshot写入磁盘

如何执行:

单独创建**fork子进程**, 先将数据写入**临时文件**, 待持久化过程结束, 再用**临时文件替换上次持久化好的文件**. 

写时复制技术

RDB的缺点**最后一次持久化后的数据可能丢失**

`dump.rdb` 最终持久化文件的默认名称

`rdbchecksum` 数据校验

`save` 只管保存, 全部阻塞, 手动保存, 不建议

`bgsave`: 在后台异步进行`snapshot`操作, 快照同时还可以响应客户端需求

### 优势

 * 适合大规模数据恢复
 * 对数据完整性和一致性要求不高更适合使用
 * 节省磁盘空间
 * 恢复速度快

### 劣势:

* Fork时内存中数据被clone一份, 2倍膨胀性需要考虑
* 虽然写时拷贝, 但是数据庞大时还是比较消耗性能
* 在备份周期在一定时间间隔做一次备份, 如果redis 意外down掉的话, 就会**丢失最后一次快照后所有的修改**

### rdb备份恢复

即`dump.rdb`的复制, 恢复

## AOF Append Only File

以**日志的形式来记录每个写操作 (增量保存**), 将redis执行过的所有**写指令**记录下来 (读操作不记录), 只追加文件不改写文件, redis启动时读取该文件重新构建数据 

### 流程

1. 客户端的请求写被append追加到AOF缓冲区中

2. AOF缓冲区根据AOF持久化策略将操作sync到磁盘的AOF文件中

3. AOF文件大小操作重写策略或者手动重写时, 会对AOF文件rewrite, 压缩AOF文件容量

4. Redis重启时, 会重新load AOF文件中的写操作达到恢复数据的目的

aof默认不开启

AOF和RDB同时开启, 默认使用AOF的数据


异常恢复

通过 `redis-check-aof--fix appendonly.aof`进行恢复

### 同步频率设置

`always` 始终同步, 每次写入立刻记入日志, 性能差完整性好

`everysec` 每秒, 如果down本秒数据可能丢失

`no` 不主动同步, 把同步时机交给操作系统

### Rewrite 重写操作

只保留可以恢复数据的最小指令集 `bgrewriteaof`

#### 原理

把rbd快照以二进制形式附在新aof头部作为已有的历史数据, 替换原来的流水账操作

默认: 大于64M的100%时开始重写 (128M)

![](./rdbyuanli.png)

### 优点

* 备份机制更稳健, 丢失数据概率更低
* 可读的日志文本, 通过操作AOF文件, 可以处理误操作

### 劣势

* 比RDB占用更多磁盘空间
* 备份速度慢
* 每次读写都同步有性能压力
* 存在个别bug造成恢复不能

## 比较 

官方推荐两个都启动

![](./bijiao1.png)

![](./bijiao2.png)

# 主从复制

主机数据更新后根据配置和策略, 自动同步到备机的master/slave机制, **Master以写为主, slave以读为主**

**一主多从**

## 优点

* **读写分离**, 性能扩展
* **容灾快速恢复**

![](./rongzaihuifu.png)

## 搭建

![](./dajian1.png)

![](./dajian2.png)



info replication 看主从状况

![](./image-20220514162846656.png)



slaveof $IP$ $PORT$

![](./image-20220514162957676.png)



注: 从机只能进行读操作

## 常用架构

### 一主二仆

* 从服务器重启后会变回主服务器

需要slaveof 重新变回从服务器, 数据重新复制

* 主服务器down, 从服务器不会变回主服务器

主服务器重启还是主服务器

### 薪火相传

- 结构化同步信息, master只和一台slave进行同步, 由slave与其他slave进行同步

### 反客为主

当主挂掉时, slave成为master

slaveof no one将slave 变为master

缺点: 需要手动完成

### 哨兵模式 sentinel 

-- 反客为主自动版

后台监控主机是否故障, 根据投票自动slave转变为master

配置: 

1. 创建 sentinel.conf 

2. 添加内容

3. ![image-20220515194201562](./image-20220515194201562.png)

   监控主机

4. sentinel监测到主机down时, 从slave中选一个变为主, 将其他从变为自己的slave, 并把原master变为slave

#### 复制延时

由于所有写都是在master上,然后再同步到slave 上, 所以会有一定的延迟, 系统繁忙时更加严重, slave数量增加也会严重

![image-20220515194742084](./image-20220515194742084.png)

每次redis实例启动会自动生成40位的runid



## 复制原理

1. slave 连上master后, 发送进行数据同步的消息
2. master接收到同步消息之后, 把主服务器数据进行持久化 rdb文件, 并发给slave, slave拿到rdb进行读取
3. 每次master进行write后, 和slave进行同步, master主动同步

全量复制 / 增量复制







# 集群

目的: 

* 解决容量不够问题

* 完成并发写操作

以前: 代理主机

​特点: 至少需要很多台服务器

## 无中心化集群

任何一台服务器都可以作为集群的入口



需要的服务器少

通过`partition`来保持`availability`



一个集群中至少要有三个主节点

分配原则尽量保证每个主数据库运行在不同的IP地址, 每个从库和主库不在一个IP地址上

什么是slot

一个redis包含16384个插槽, 数据库中的key对应插槽中的一个

根据k计算所在插槽的数

---

集群中 某部分主从全部挂掉

* 可以配置为是否全部挂掉 还是只挂掉对应的数据

### 优点

* 实现扩容 
* 分摊压力
* 无中心配置相对简单

### 缺点

* 不支持多键操作

* 多键redis事务不支持
* lua脚本不支持
* 迁移复杂度较大

# 应用问题

## 缓存穿透

现象:

1. 应用服务器压力变大

2. redis命中率降低

3. 一直查询数据库

4. 造成数据库崩溃

    
原因:

1. **redis查询不到数据**

2. **出现很多非正常url访问**

3. 多出现在恶意攻击

### 解决方案

1. 对空值缓存, 设置空结果的过期时间很短
2. 设置可访问的名单(白名单)
   * bitmaps定义可以访问的名单, 如果访问id不在bitmaps里命啊不允许访问
     * ​	缺点 效率不高

3. 采用`bloom filter`: 实际上是一个很长的二进制向量和一系列随机映射函数(hash)
4. 实时监控: 当发现redis命中率开始急剧降低, 进行排查 

## 缓存击穿

现象:

​1. 数据库访压力瞬时增加

​2. redis里没有出现大量key过期

3.  redis正常运行

原因:

1. **redis中某个key过期了, 大量访问使用这个key**

### 解决:

1. 预设热门数据到redis中, 加大这些key的时长
2. 实时调整
3. 使用锁
   1. 在缓存失效的时候不是立即去load db
   2. 先使用缓存工具的某些带成功操作返回值的操作去set mutex key
   3. 当操作返回成功的时候, 再进行load db 操作, 并设回缓存, 最后删除mutex

## 缓存雪崩

现象

1. 数据库压力变大, 服务器崩溃

原因:

1. **在极少时间内, 查询大量key的集中过期情况**

### 解决

1. 构建多级缓存架构 `nginx` + `redis` + 其他缓存等
2. 使用锁或队列
   1. 不适用高并发的场景
3. 设置过期标志更新缓存
   1. 记录缓存数据是否过期, 如果过期会出发通知另外的线程在后台去更新实际key的缓存
4. 将缓存失效时间散开
   1. 在原有失效时间的基础上加一个随机值, 过期时间的重复率就会降低

## 分布式锁

原因: 单机部署的锁不能跨jvm

适用于集群分布式的锁的使用方法

### 实现方案

1. 基于数据库实现分布式锁
2. 基于缓存 (redis等)
3. 基于zookeeper

优缺点:

1. 性能: redis最高
2. 可靠性: zookeeper最高

### 适用redis 配置分布式锁


![image-20220522092100472](./image-20220522092100472.png)

释放锁 `del key`

一直释放: 设置过期时间

1. 使用setnex上锁
2. 使用del释放锁
3. 锁一直没有释放, 设置过期时间, 自动释放
4. 上锁后突然出现异常, 无法设置过期时间
   * 上锁的时候同时设置过期时间
   * set key value nx ex time 原子化操作

### UUID 防止误释放

在上锁的时候为每个服务器设置一个唯一uuid

释放锁的时候, 判断当前uuid是否和要释放锁uuid是否一样

### LUA保证操作原子性

问题: 删除操作缺乏原子性

![image-20220522095822238](./image-20220522095822238.png)

锁需要确保:

​	* 互斥性

​	* 不会发生死锁

​	* 解铃还需系铃人

​	* 加锁和解锁需要原子性

# redis 6.0新功能

## ACL

提供更fine-grained 的控制


```
acl list

展示用户
```

![image-20220522100442638](./image-20220522100442638.png)

```
acl cat string

acl whoami

acl setuser user1
```




## IO多线程

多线程程只是用来处理网络数据读写和协议解析

需要配置才能使用



## 工具支持cluster

ruby集成在了redis中

