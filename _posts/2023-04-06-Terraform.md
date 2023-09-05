---
title: Terraform 基础使用方法与特性
toc: true
date: 2023-04-06 08:37:31
tags: [DevOps, Tools]
keywords:
description:
password:
abstract:
message:
layout: post
---

# General

## 1. 是什么 What is Terraform?

* 用于基础设施置备 Infrastructure Provisioning

> 什么是**基础设施置备**?
> 在我们需要将工程/系统部署到云端时, 我们通常需要准备对应的基础设施, 以 AWS 为例, 我们需要准备私有网络空间 Private network space, EC2服务器实例 server instances, 配置安全组 Security, 以及下载其他工具框架(如 Docker). 这一系列创建与准备工作一般认为是基础设施置备 Infrastructure Provisioning. 

<!-- more -->

## Ansible 和 Terraform 的区别? 

Difference between Ansible and Terraform?

在官方文档中, Terraform的描述与Ansible很相似

> **Terraform**: Terraform Cloud enables infrastructure automation for provisioning, compliance, and management of any cloud, datacenter, and service.
> 
> **Ansible**: Ansible is a suite of software tools that enables infrastructure as code. It is open-source and the suite includes software provisioning, configuration management, and application deployment functionality.

相同点: 

* 同样是IaaC(Infrastrucutre as a Code)

* 都自动化了基础设施的置备, 配置, 以及管理

不同点: 

* Terraform 主要是基础设施置备工具, 同时可以用于部署程序
* Ansible 主要是配置管理工具, 这意味着Ansible更多倾向于管理**已经置备完成**的基础设施, 并对其进行配置, 部署, 更新软件等

基于上面两个工具的区别, 我们通常可以同时使用两者, 使用Terraform进行基础设施置备, 并使用Ansible进行配置管理

## 工具特点 Characteristics

* 开源 Open Source
* 声明式 Declarative

> 什么是 Declarative 语句?
> 在配置文件中, 你只需要定义最终状态 (end state) -- **What**
>
> 比如说, 你可以声明, 需要5台有特定配置的服务器; 拥有特定权限的 AWS user
>
> 相对的命令式 Imperative 语句定义了具体的每一步应该如何执行 -- **How**
>
> Declarative 语句在更新基础设施时更加简单
>
> Imperative: 移除两个服务器, 添加防火墙配置, 增加 AWS user 权限 -- 由管理员给出指示
>
> Declarative: 现在我们有n-2个服务器, 使用这个防火墙配置, AWS user 有如下的权限 -- 由工具自己确定哪些需要完成







## 使用场景

* 管理现有基础设施
  * 创建
  * 修改
* 复制基础设施


## Terraform 架构

### Core

输入:

TF-config: 用户配置的设置 (目标配置)

State: 当前阶段的设置 (当前配置)

作用: 

Core通过比较两个输入, 作出执行计划: 哪些需要创建/更新/销毁?


### 服务提供者 Providers

IaaS: AWS / Azure

PaaS: Kubernetes

SaaS: Fastly

通过对应的 Provider 完成基础设施配置

# 基础命令

**refresh**

询问基础设施提供者获取当前 State


**plan**

创建执行计划

决定需要执行哪些动作来到达目标 State

**apply**

执行 plan 中创建的计划

**destroy**

摧毁资源/基础设施


# 实践

1. 下载 

* MacOS

```
> brew install terraform
# 使用 homebrew 下载
> terraform -v
# 查看版本号, 确认安装成功
```

* Win
* Linux

创建一个配置文件

倒入服务 provider 及其一些基础变量
```
provider “aws" {
    region = "us-east-1"
} 
```

## 创建资源

基本语法

```
resources "<provider>_<services>" "name" {

    param1 = ""
    param2 = “”
}

```

terraform 命令

```
>terrafrom init

Initializing the backend...

Initializing provider plugins...

```
用于初始化terraform后端, 下载对应的provider 插件


```

> terraform plan 
......

Plan: 1 to add, 0 to change, 0 to destroy.

```

规划, 检查语句, 规划对应更新

```
>terraform apply
...

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

具体执行代码


## 修改资源

当我们执行完成后, 如果我们再执行一次 apply, 会是什么结果?

因为terraform使用declarative语言, config文件中定义的是基础设施的最终状态, 也就是说, 如果使用目前的config, 不论我们执行多少次 apply, 在AWS中都只会存在一个instance

## 删除资源

```
>terrafrom destroy

```
删除所有基础设施



## 引用资源

接下来尝试在AWS中创建一个subnet.

在AWS中subnet需要在VPC中进行创建, 也就是说我们需要对创建的VPC进行引用

```
resource "aws_vpc" "first-vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
      "Name" = "production"
    }
}

resource "aws_subnet" "subnet-1" {
    vpc_id = aws_vpc.first-vpc.id
    cidr_block = "10.0.1.0/24"
    tags = {
      "Name" = "prod-subnet"
    }
  
}

```

在这里 我们使用`vpc_id = aws_vpc.first-vpc.id`对vpc的id进行引用

* 在这里, 两个resources的资源定义顺序**不会**影响引用的效果, terraform会自动确定资源之间的依赖关系


## Terraform 相关文件

* .terraform文件夹


在使用init, plan, deploy等相关命令中, 会有相关文件被自动加载在 .terraform 文件夹中 (类似.git)

* terraform.tfstate 

存储了当前的config定义的state状态



## Other Commands

* terraform state list

展现 terraform 中所有的 resources

* terraform state show \<name of resource>

展现某个具体 resource 的细节

如果我们想要在`terraform apply`完成后自动print对应的资源细节, 在tf文件中添加对应的output

```
output "server_public_ip" {
  value = aws_eip.one.public_ip
}

```

之后当执行`terraform apply` 时, 在命令行中就可以自动打印对应的信息


在文件中定义之后, 可以使用 `terraform output` 直接查看部署时获得的output. 同时, 我们也可以通过`terraform refresh` 刷新对应output的状态


* 定位resource

```
> terraform destroy -target aws_instance.web-server-instance

```

通过定义 `-target` 旗帜来具体的删除某个资源


同样的, 我们也可以在`terraform apply` 时定义`-target`来具体的启动某一个资源

## Variables

terraform 支持定义变量variables来是我们对于某些变量的定义

```
variable "subnet_prefix" {
    description = “cidr block for the subnet”
    # default 
    type = string
}
```
一个变量有如上三个可选属性

### 引用变量


```
resource "aws_subne" "subnet-1" {
  vpc_id = aws_vpc.prod-vpc.id
  cidr_block = var.subnet_prefix
  ...
}

```

上面我们使用`var.subnet_prefix`定义了`cidr_block`的内容, 如果这时候我们再执行`terraform apply`, terraform会在命令行中要求我们填写对应变量的值

1. prompt 传值
当然这样在执行的时候会需要我们对于每一个prompt都要输入对应变量的值,实际操作很麻烦

2. `-var` 传值
我们可以在`terraform apply`时增加`-var`并定义对应变量的值, 这样就不需要使用prompt的模式填写变量了

3. `.tfvars` 传值
在实际使用中, 更常用的方法其实是使用的一个单独的文件来进行变量的存储. 在执行terraform命令时, 会自动查找一个 `terraform.tfvars` 的文件, 我们可以在这个文件中定义对应变量的名称, 从而减少输入命令行时的重复操作

in terraform.tfvars
```
subnet_prefix = "10.0.0.0/24"
```

此外, 我们可以重命名此变量文件, 并在`terraform apply`时使用 `-var-file` 确定具体需要使用的var文件

```
>terraform apply -var-file example.tfvars

```

使用这种方法可以让我们更加方便的对于不同配置的集群进行不同变量定义的部署

