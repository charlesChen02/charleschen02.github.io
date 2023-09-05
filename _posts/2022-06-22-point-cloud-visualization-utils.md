---
title: Point Cloud Visualization Utils
toc: true
date: 2022-06-22 11:23:16
tags: [Memo]
keywords:
description:
password:
abstract:
message:
layout: post
---



1.   Codes for visualizing point clouds (without labels)

```python
import pyvista as pv
pv.start_xvfb() # start a session

point_clouds = ShapeNet(root='../dataset/shapenet', split='trainval')
pcd = point_clouds[0].pos.cpu().detach().numpy() # pick a specific point cloud data from the dataset
points = pv.PolyData(pcd) # plot the dataset
points.plot(jupyter_backend='panel') # set the visualization interactive

```

<!-- more -->