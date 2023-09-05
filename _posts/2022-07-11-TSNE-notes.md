---
title: Use T-SNE for a better visualization
toc: true
date: 2022-07-11 10:31:11
tags: [t-SNE, Machine Learning, Visualization, Notes]
keywords: 
description:
password:
abstract:
message:
layout: post
---


# Definition

t-distributed stochastic neighbor embedding (t-SNE) is a methods to visualise high dimension data by transforming each data into a two or three dimensional map. It models in a way that similar objects are modeled by nearby points and dissimilar objects are modelled by distant points with high probability.

<!-- more -->

# Stages

1. constructs a probability distribution over pairs of high-dimensional objects in such a way that similar objects are assigned a higher probability while dissimilar points are assigned a lower probability.
2. t-SNE defines a similar probability distribution over the points in the low-dimensional map, and it minimise the KL divergence between the two distributions with respect to the locations of the points in the map.



# Demo Code

```python
# simple example
import numpy as np
from sklearn.manifold import TSNE
X = np.array([[0, 0, 0], [0, 1, 1], [1, 0, 1], [1, 1, 1]])
X_embedded = TSNE(n_components=2, learning_rate='auto',init='random').fit_transform(X)
X_embedded.shape
```

## Parameters for sklearn.manifold.TSNE

> Source: [`sklearn.manifold`.TSNE](https://scikit-learn.org/stable/modules/generated/sklearn.manifold.TSNE.html)

Parameters:

```xml
n_components: int, default=2
Dimension of the embedded space.

perplexity: float, default=30.0
The perplexity is related to the number of nearest neighbors that is used in other manifold learning algorithms. Larger datasets usually require a larger perplexity. Consider selecting a value between 5 and 50. Different values can result in significantly different results.

early_exaggeration: float, default=12.0
Controls how tight natural clusters in the original space are in the embedded space and how much space will be between them. For larger values, the space between natural clusters will be larger in the embedded space. Again, the choice of this parameter is not very critical. If the cost function increases during initial optimization, the early exaggeration factor or the learning rate might be too high.

learning_rate: float or ‘auto’, default=200.0
The learning rate for t-SNE is usually in the range [10.0, 1000.0]. If the learning rate is too high, the data may look like a ‘ball’ with any point approximately equidistant from its nearest neighbours. If the learning rate is too low, most points may look compressed in a dense cloud with few outliers. If the cost function gets stuck in a bad local minimum increasing the learning rate may help. Note that many other t-SNE implementations (bhtsne, FIt-SNE, openTSNE, etc.) use a definition of learning_rate that is 4 times smaller than ours. So our learning_rate=200 corresponds to learning_rate=800 in those other implementations. The ‘auto’ option sets the learning_rate to max(N / early_exaggeration / 4, 50) where N is the sample size, following [4] and [5]. This will become default in 1.2.

n_iter: int, default=1000
Maximum number of iterations for the optimization. Should be at least 250.

n_iter_without_progress: int, default=300
Maximum number of iterations without progress before we abort the optimization, used after 250 initial iterations with early exaggeration. Note that progress is only checked every 50 iterations so this value is rounded to the next multiple of 50.

New in version 0.17: parameter n_iter_without_progress to control stopping criteria.

min_grad_norm: float, default=1e-7
If the gradient norm is below this threshold, the optimization will be stopped.

metricstr or callable, default=’euclidean’
The metric to use when calculating distance between instances in a feature array. If metric is a string, it must be one of the options allowed by scipy.spatial.distance.pdist for its metric parameter, or a metric listed in pairwise.PAIRWISE_DISTANCE_FUNCTIONS. If metric is “precomputed”, X is assumed to be a distance matrix. Alternatively, if metric is a callable function, it is called on each pair of instances (rows) and the resulting value recorded. The callable should take two arrays from X as input and return a value indicating the distance between them. The default is “euclidean” which is interpreted as squared euclidean distance.

metric_params: dict, default=None
Additional keyword arguments for the metric function.

New in version 1.1.

init: {‘random’, ‘pca’} or ndarray of shape (n_samples, n_components), default=’random’
Initialization of embedding. Possible options are ‘random’, ‘pca’, and a numpy array of shape (n_samples, n_components). PCA initialization cannot be used with precomputed distances and is usually more globally stable than random initialization. init='pca' will become default in 1.2.

verbose: int, default=0
Verbosity level.

random_state: int, RandomState instance or None, default=None
Determines the random number generator. Pass an int for reproducible results across multiple function calls. Note that different initializations might result in different local minima of the cost function. See Glossary.

method: str, default=’barnes_hut’
By default the gradient calculation algorithm uses Barnes-Hut approximation running in O(NlogN) time. method=’exact’ will run on the slower, but exact, algorithm in O(N^2) time. The exact algorithm should be used when nearest-neighbor errors need to be better than 3%. However, the exact method cannot scale to millions of examples.

New in version 0.17: Approximate optimization method via the Barnes-Hut.

angle: float, default=0.5
Only used if method=’barnes_hut’ This is the trade-off between speed and accuracy for Barnes-Hut T-SNE. ‘angle’ is the angular size (referred to as theta in [3]) of a distant node as measured from a point. If this size is below ‘angle’ then it is used as a summary node of all points contained within it. This method is not very sensitive to changes in this parameter in the range of 0.2 - 0.8. Angle less than 0.2 has quickly increasing computation time and angle greater 0.8 has quickly increasing error.

n_jobs: int, default=None
The number of parallel jobs to run for neighbors search. This parameter has no impact when metric="precomputed" or (metric="euclidean" and method="exact"). None means 1 unless in a joblib.parallel_backend context. -1 means using all processors. See Glossary for more details.

New in version 0.22.

square_distances: True, default=’deprecated’
This parameter has no effect since distance values are always squared since 1.1.
```

Attributes:

```xml
embedding_: array-like of shape (n_samples, n_components)
Stores the embedding vectors.

kl_divergence_: float
Kullback-Leibler divergence after optimization.

n_features_in_: int
Number of features seen during fit.

New in version 0.24.

feature_names_in_: ndarray of shape (n_features_in_,)
Names of features seen during fit. Defined only when X has feature names that are all strings.

New in version 1.0.

n_iter_: int
Number of iterations run.
```

Methods:

```python
fit(X[,y]) # fit X into a embedded space
fit_transform(X[,y]) # fit X into an embedded space and return that transformed output
get_params([deep]) # Get parameters for this estimator
set_params(**params) # set the parameters of this estimator
```



# Algorithm details







# Compare to other dimensionality reduction methods



## PCA

dense data



## Truncated SVD

sparse data

