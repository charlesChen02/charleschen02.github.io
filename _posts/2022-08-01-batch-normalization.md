---
title: Batch Normalization
toc: true
date: 2022-08-01 12:09:30
tags: [Machine Learning, Batch Normalization]
keywords:
description:
password:
abstract:
message:
layout: post
---



# Why

Model is updated layer-by-layer backward from the output to the input using estimate of error

Because all layers are changed during an update, the update procedure is forever chasing a moving target

<!-- more -->

E.g. the weights of a layer are updated expecting the prior layer outputs values with given distribution, but this distribution will change after the weights of the prior layers are updated



## Internal Covariate Shift

The the gradient descent proceed, the parameters in each layer would update, making the output distribution change, therefore the tar for the next layer changes, the next layers has to learn the distribution that keeps changing.

### Influence

* deep layers have to keep adjusting to learning the input distribution, lower the convergence speed.
* the training tend to go to the saturated space of the activation
    * Solution
        1. Using non saturated activation function
        2. make the input distribution of the activation in a stable situation, to help it away from the saturated place.



# What

Batch Normalization is proposed as a technique to help coordinate the update of multiple layers in the model

Scaling the output of the layer, by standardizing the activations of each input variable per mini-batch, such as the activations of a node from the previous layer. (Standardization refers to rescaling data to have a mean of zero and standard deviation of one)

Standardizing the activations of the prior layer means that assumptions the subsequent layer makes about the spread and distribution of inputs during the weight update will not change dramatically. 

This has the effect of stabilizing and speeding-up the training process of deep neural networks.

Normalizing the inputs to the layers has an effect on the training of the model, dramatcally reducing the number of epochs required. It can also have a regularizing effect. Reducing generalization error much like the use of activation regularization.

## Equations

$$
\hat x = \frac{x - mean}{\sqrt{var + eps}} 
$$

use two extra parameter $\gamma$  and $\beta$ to make recover the expression ability for the data:
$$
\hat Z_j = \gamma_j Z_j + \beta_j
$$
During testing, we use the average mean and variance from the training procedure:
$$
\mu_{test} = E(\mu_{batch})
$$




## Whitening

PCA whitening and ZCA whitening for each layer in every epoch 

### Aim:

* make the input features have the same mean and standard deviation
* remove relevance between features

## Batch Normalization

### why not using whitening?

* Expensive computation cost
* Whitening process change the distribution of each layer, therefore change the expressiveness of data in each layer. The parameters learned in lower layers would get lost by whitening.



### Idea

simplify the computation, normalization for every features, and let every feature has mean 0 and deviation 

add the linear transform to make those data revive their expressiveness as much as possible



# Batch Renormalization

For small mini-batches that do not contain a representative distribution of examples from the training dataset, the difference in the standarized inputs between training and inference can result in noticeable difference in performance. 

Batch Renormalization makes the estimate of the variable mean and standard deviation more stable across mini-batches.





# Practice

In practice, it is common to allow the layer to learn a new mean and standard deviation, beta and gamma, that wallow the automatic scaling and shifting of the standarized layer inputs. 

```python
import torch
import torch.nn as nn


'''
X.shape = [b, c, h, w] for 2d
X.shape = [b, d] for 1d
'''
def batch_norm(is_training, X, gamma, beta, moving_mean, moving_var, eps, momentum):
		if not is_training:
      	X_h = (X - moving_mean) / torch.sqrt(moving_var + eps)
    else:
      	feature_shape = len(X.shape)
        assert feature_shae in (2, 4)
        
        if feature_shape == 2:
         # for norm1d
        		mean = X.mean(dim = 0)
          	var = ((X - mean) ** 2).mean(dim = 0)
            
        else:
          	mean = X.mean(dim = (0,2,3), keepdim = True)
            var = ((X - mean) ** 2).mean(dim = (0, 2, 3), keepdim = True)
        X_h = (X - mean) / torch.sqrt(var + eps)
        
        # momentum smoothing
        moving_mean = momentum * moving_mean + (1. - momentum) * mean
        moving_var = momentum * moving_var + (1. - momentum) * var
    Y = gamma * X_h + beta
  	return Y, moving_mean, moving_var

class _BatchNorm(nn.Module):
  	def __init__(self, num_features, num_dims, momentum):
    		super(_BatchNorm, self).__init__()
        assert num_dims in (2, 4)
        if num_dims == 2:
          	shape = (1, num_dims)
       	else:
          	shape = (1, num_features, 1, 1)
            self.gamma = nn.Parameter(torch.ones(shape))
            self.beta = nn.Parameter(torch.zeros(shape))
            self.moving_mean = torch.zeros(shape)
            self.moving_var = torch.zeros(shape)
            self.momentum = momentum
    def forward(self, X):
      	Y, self.moving_mean, self.moving_var = batch_norm(self.is_training, X, self.gamma, self.beta, self.moving_mean, self.moving_var, eps=1e-5, momentum = self.momentum)
        return Y
class BatchNorm1d(_BatchNorm):
    def __init__(self, num_features, momentum=0.9):
        super().__init__(num_features, 2, momentum)

class BatchNorm2d(_BatchNorm):
  	def __init__(self, num_features, momentum=0.9):
        super().__init__(nums_features, 4, momentum)

```





# Comparison



## With layer normalization

* BN work for a batch of training examples, where LN work for single sample.

* BN standardize across features for samples, where LN standardize for all features in the single sample
* LN better used in NLP