---
title: 经常遇到的 venv cuda broke 问题分析与解决
toc: true
date: 2022-05-31 09:54:41
tags: [Machine Learning, Cuda, Pytorch]
keywords: [machine learning, cuda, pytorch, 报错, 虚拟环境, torch,torchvision,torchaudio]
description: 处理虚拟环境中显卡cuda不匹配问题
password:
abstract:
message:
layout: post
---

# 问题

使用autodl的时候, 用`pip install -r requirements.txt`下载代码要求的包之后, 发现训练直接开始报错. 

<!-- more -->

一些环境的参数:

```
显卡型号: RTX A5000 显存:24GB

镜像版本:
PyTorch  1.10.0
Python  3.8
Cuda  11.3

CPU:
15核 AMD EPYC 7543 32-Core Processor
内存:30GB
```

报错的内容为:

```
NVIDIA GeForce RTX A5000 with CUDA capability sm_86 is not compatible with the current PyTorch installation. The current PyTorch install supports CUDA capabilities sm_37 sm_50 sm_60 sm_70.
If you want to use the NVIDIA GeForce RTX A5000 GPU with PyTorch.

```

# 解决方法

**简单版: 卸载当前环境中torch, torchvision, torchaudio, 使用[pytorch官方](https://pytorch.org/get-started/locally/)指定的下载方式执行对应可执行cuda版本的pytorch**

eg. (具体需要通过上面的连接来确定具体下载的命令)

```shell
pip uninstall torch torchvision torchaudio
pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113
```

---

## 问题分析

乍一看像是pytorch版本出了问题, 因为当时通过`nvidia-smi`以及`nvcc --version`都看到了cuda版本为11.3, 而11.3版本目前是支持sm_86架构的. 

后来看了[这个](https://discuss.pytorch.org/t/need-help-trouble-with-cuda-capability-sm-86/120235/6), 检查了一下虚拟环境中pytorch连接的对应的cuda版本:

```python
import torch
torch.version.cuda
```

\> 10.2

这下问题明确了, 即虚拟环境中pytorch自动连接的cuda版本出了问题, 不能支持设备上的显卡, 而上述两个命令查询的都是实体环境的状态. 

如果要解决, 需要先卸载当前虚拟环境中的torch相关组件: torch, torchvision, torchaudio

```
(s) root@container-8fb311963c-c800a7a5:/home# pip uninstall torch torchvision torchaudio
```

然后再使用[官网](https://pytorch.org/get-started/locally/)提供的下载方式, 指定cuda版本, 重新下载: 

![image-20220531095130395](./image-20220531095130395.png)

```
pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu113
```

安装完成后再次检查cuda版本号:

```
import torch
torch.version.cuda
```

\> 11.3

问题解决, 可以开始训练了.

![image-20220531095342135](./image-20220531095342135.png)



