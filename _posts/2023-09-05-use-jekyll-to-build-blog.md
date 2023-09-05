---
layout: post
title:  "Mac系统使用jekyll创建一个博客"
date:   2023-09-05 10:50:38 +0800

---

因为hexo版本更新后总是有各种各样的问题，所以终于决定把现有的博客换掉了，目前的计划是使用jekyll

# 下载

根据官方的教程，在mac上下载jekyll还是比较简单的：

```

  gem install bundler jekyll

  jekyll new my-awesome-site

  cd my-awesome-site

  bundle exec jekyll serve

```

因为mac本身自带了ruby和gem的包，所以可以直接使用对应的命令行

但是本人在具体使用时直接报错：

```
(base) chaos@Charles-MacBook-Pro ~ % gem install bundler jekyll
Fetching bundler-2.4.19.gem
ERROR:  While executing gem ... (Gem::FilePermissionError)
    You don't have write permissions for the /Library/Ruby/Gems/2.6.0 directory.
```
懒得进行问题定位和解决了，后面直接自己重新配置了一套ruby环境使用，省得遇到各种权限问题

## 使用自己下载的ruby环境进行配置
使用homebrew重新下载ruby并进行对应配置：

```
brew install ruby
```
安装完成后， 修改.bashrc文件, 使系统调用时使用brew下载的ruby而不是系统自带的文件:

```
echo 'export PATH="/usr/local/opt/ruby/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```
ps: 路径需要配置为brew下载的ruby的bin路径位置, 可以通过

```
brew list ruby
```

查询ruby下载位置

### 配置gem运行环境

```
echo 'export PATH="$HOME/.gem/ruby/X.X.0/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```
配置完成后就可以使用自己的ruby和gem下载jekyll

```
gem install --user-install bundler jekyll

```


## 配置国内镜像源

由于国内的防火墙阻断了和 ruby 服务器的链接，ruby 的资源文件存放在 Amazon 的服务器上，好像好多国外的云空间都存放在 Amazon 的服务器上，在中国都不能正常访问。

```
$ gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
$ gem sources -l
https://gems.ruby-china.com
```


# 创建一个新的blog

根据官方的建议, 创建一个实例:

```
$ jekyll new my-site
$ cd my-site
```

进入目录后

```
bundle exec jekyll serve

```
完成后就可以在 http://127.0.0.1:4000/ 查看jekyll的默认站点的样子了.

