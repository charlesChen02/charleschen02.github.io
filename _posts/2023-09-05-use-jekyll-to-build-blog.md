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

# 创建一篇post

当使用上面的命令创建了新站点文件之后, 内部的文件通常包含了一个叫做 `_post` 的文件夹, 这就是jekyll用来存放具体博客的位置.

一般情况下, jekyll的post名称要求是使用 `YYYY-MM-DD-Title` 的格式进行命名, 同时在所创建的文件内部需要添加头部信息, 类似下面的:

```

---
layout: post
title:  "这是一个标题"
date:   2023-09-05 10:50:38 +0800

---

```

其中这里面 `layout` 定义了这个页面的格式, 可以在站点根目录下`_layout` 文件夹中创建对应的格式文件.

## 自动化创建一篇post

毕竟手动创建并填写这些东西实在是太麻烦了, 所以我们可以通过一个`gem`插件实现使用命令行自动创建一篇post并且自动填好这些基本的信息:

在站点根目录的 `Gemfile` 中, 添加:

```
gem 'thor'
gem 'stringex'
```

执行命令

```

bundle install

```

在根目录下创建一个`jekyll.thor`的文件, 并写入下面的内容:

```
require "stringex"
class Jekyll < Thor
  desc "new", "create a new post"
  method_option :editor, :default => "subl"
  def new(*title)
    title = title.join(" ")
    date = Time.now.strftime('%Y-%m-%d')
    filename = "_posts/#{date}-#{title.to_url}.markdown"

    if File.exist?(filename)
      abort("#{filename} already exists!")
    end

    puts "Creating new post: #{filename}"
    open(filename, 'w') do |post|
      post.puts "---"
      post.puts "layout: post"
      post.puts "title: \"#{title.gsub(/&/,'&amp;')}\""
      post.puts "tags:"
      post.puts " -"
      post.puts "---"
    end

    system(options[:editor], filename)
  end
end

```

简单来说, 这就是一个thor脚本, 需要输入title参数, 并且根据今日日期自动填写其他的内容

做完上面这些东西后, 我们可以使用命令:

```
$ thor jekyll:new title of the new post

```

进行新post的创建了.

## 插入图片

可以使用

```
<img src="" alt="" style="max-width:100%; height:auto;">
```
来将md文件中的图像限定为和页面一样宽