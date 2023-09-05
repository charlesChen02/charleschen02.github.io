---
title: Graph Neural Network Notes
toc: true
date: 2022-08-16 12:59:41
tags:
  - Computer Vision
  - GNN
  - Machine Learning
  - Notes
keywords:
description:
password:
abstract:
message:
layout: post
---





>   Video Link on Youtube: [An Introduction to Graph Neural Networks: Models and Applications](https://www.youtube.com/watch?v=zCEYiCxrL_0)

# Intro



## Distributed Vector Representations

![image-20220531111133794](./image-20220531111133794.png)

From one-hot -> multiply with embedding matrix and get distributed rep.

![image-20220531111258366](./image-20220531111258366.png)

<!-- more -->


## Graph Notation Basics

*   Nodes/Vertices
*   Edges
*   $G=(V,E)$



# Graph Neural Network

By training, each node's vector contains information relative to the whole graph, instead of the initial representation.

![image-20220531111630964](./image-20220531111630964.png)

*   GNNs Synchronous Message Passing (All-to-All)

*   Output:
    *   Node selection
    *   Node classification
    *   Graph classification

## Gated GNNs

![image-20220531121358147](./image-20220531121358147.png)

GRU: Gated Recurrent Network

![image-20220531121450912](./image-20220531121450912.png)

*   permutation invariant -> Sum

## GCN

**Trick 1: backwards Edges**

![image-20220531121608345](./image-20220531121608345.png)

*   For each forward edge, add a backward edge

## Graph Notations - Adjacency Matrix

![image-20220531121936642](./image-20220531121936642.png)

## GGNN as Matrix Operation

![image-20220531122100994](./image-20220531122100994.png)

# Express as code

-   einsum

```python
C = np.einsum('bd,qd->bq', A, B)
D = np.einsum('abs,be,abq->cqe',A,B,C)
```

![image-20220531122456233](./image-20220531122456233.png)

![image-20220531122502189](./image-20220531122502189.png)

```python
def GGNN(initial_node_states, adj):
    node_states = initial_node_states #[N,D]
    for i in range(num_steps):
        messages = {}
        for k in range(num_message_types):
            message[k] = einsum('nd,dm-nm', edge_transform, node_states) # [N, M]
        received_messages = zeros(num_nodes, M) # (N, M)
        for k in range(num_message_types):
            received_messages += einsum('nm,ml->lm', message[k], adj[k])
        node_states = GRU(node_states, received_messages)
    return node_states
  
```
**Notes**: The adjancency matrix can be very large and sparse

# Common Arch of Deep Learning Code

![image-20220531123935257](./image-20220531123935257.png)

