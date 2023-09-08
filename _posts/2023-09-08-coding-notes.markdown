---
layout: post
title: 刷题笔记
tags:
 -
---


# 2023

## Sep

### 08

**128.最长连续序列**
> 难度: Leetcode中等

> 给定一个未排序的整数数组 nums ，找出数字连续的最长序列（不要求序列元素在原数组中连续）的长度。

> 请你设计并实现时间复杂度为 O(n) 的算法解决此问题。


思路: *枚举+哈希表* 用哈希表记录组内元素, 以每一个元素作为开头进行枚举, 计算以当前元素为起始的最长的连续序列长度. 为了方式重复计算, 会额外判断当前数字的前序数是否已经存在, 即只会以每一个连续序列的最小数作为起始开始计算.


```python
class Solution:
    def longestConsecutive(self, nums: List[int]) -> int:
        res = 0
        s = set(nums)

        for a in s:
            if a - 1 not in s:
                cur = a
                cres = 1
                while cur + 1 in s:
                    cres += 1
                    cur += 1
                res = max(cres, res)
        return res
```

**G - Sqrt**

> 纯鉴赏, 争取早日上瓜


```
难度:2032
输入 T(≤20) 表示 T 组数据。
每组数据输入 X(1≤X≤9e18)。
请构造一个长为 10^100 的数组 a，满足：
1. a[i] 均为正整数。
2. a[0] = X。
3. a[i] * a[i] <= a[i-1]。
输出你可以构造出多少个不同的数组。

输入
4
16
1
123456789012
1000000000000000000

输出
5
1
4555793983
23561347048791096

```

思路:
```
下标从 0 开始。

提示 1：
枚举 a[2]，那么 a[1] 的范围就确定了。
设 m = floor(sqrt(a[0]))。
那么 a[1] 的范围就是 [a[2]*a[2], m]，这一共有 m-a[2]*a[2]+1 个数，这些数都可以是 a[1]。

提示 2：
定义 f[i] 表示序列的首项为 i 时，可以构造出多少个不同的数组。
根据提示 1，有
f[i] = sum(f[j] * (m-j*j+1))，这里 1 <= j <= sqrt(m)。

提示 3：
预处理出 f[1] 到 f[54772]，就可以直接用上式算出 f[X]。这里 54772 = floor(pow(9e18, 0.25))。
预处理可以不用像上式那样复杂，枚举 a[1]，可以得到
f[i] = sum(f[j])，这里 1 <= j <= sqrt(i)。
这个式子又可以化简成
f[i] = f[i-1] + (i 是完全平方数 ? f[floor(sqrt(i))] : 0)

https://atcoder.jp/contests/abc243/submissions/45083883
```

题解:

```python

import math

if __name__ == '__main__':
    f, r = [0 for _ in range(55000)], 2
    f[1] = 1
    for i in range(2, len(f)):
        f[i] = f[i - 1]
        if r * r == i:
            f[i] += f[r]
            r += 1
    for _ in range(int(input())):
        m, ans, i = int(input()), 0, 1
        v = int(math.sqrt(m))
        if v * v > m:
            v -= 1
        while i * i <= v:
            ans += f[i] * (v - i * i + 1)
            i += 1
        print(ans)

```