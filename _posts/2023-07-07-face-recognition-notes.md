---
title: 人脸识别项目实战笔记
layout: post
date: 2023-07-07 13:47:27
---



# 前言

人脸识别的主要流程包括了: 人脸检测, 人脸归一化, 人脸信息编码 大致的三个流程. 其中人脸检测和人脸信息编码这两个部分可以使用深度学习模型进行数据的处理以达到更好的效果. 

除了从模型框架开始手搓整体的框架之外, 现有一些即插即用的人脸识别框架也能够满足项目部署的实际使用, 如 `deepface`, `dlib`, `opencv` 等. 在本篇博客中将分别介绍由自己构建的一套人脸识别框架, 以及使用 `dlib` 进行开发的流程


# 基于 FaceNet 和 RetinaFace 开发的框架

对于人脸识别的项目来说, 我们有一个存有人员面部照片的数据库 (身份证证件照), 当相机捕捉到新的人脸时, 我们需要与数据库中的照片进行比较. 判断人员的身份. 

## 人脸信息注册

我们首先需要创建人脸数据信息的gallery, 大致的逻辑如下

```
对于数据库中的每张照片, 执行人脸检测, 人脸信息编码操作
将保存的人脸信息存入文件中, 以待未来的使用
```

在项目中, 我们先使用 `Facenet` 进行目标的识别

```python
mtcnn = MTCNN(image_size=160, 
              margin=0, 
              min_face_size = 20, 
              device=device,
              )

resnet = InceptionResnetV1(classify=False,
                            pretrained='vggface2',
                            num_classes=0
                           ).eval().to(device)

```

在实操中, `mtcnn` 和 `resnet` 分别用于人脸检测和信息编码. 

```python
def detect_faces(path, file_name):
    img = Image.open(os.path.join(path, file_name))
    img_face = mtcnn(img)

    img_embedding = resnet(img_face.unsqueeze(0).to(device))

    return img_embedding, file_name

```

对于单张图片, 我们首先使用`mtcnn`进行人脸位置的检测, 之后我们使用`resnet`提取512D的人脸编码信息. 

```python
person_names = []
face_embeddings = []
folders = os.listdir(path)
for folder in tqdm(folders):
    new_path = path+'/'+folder+'/'
    files = os.listdir(new_path)
    for file_name in files:
        if valid_extension(file_name):
            try:
                img_embedding, person_name = detect_faces(new_path, file_name)
                person_names.append(person_name)
                face_embeddings.append(img_embedding.detach().cpu().numpy())
                print("Registering {}".format(person_name))
            except Exception as e:
                print("Error occured during process", file_name)
                print(e)
# store known info
with open("registry.pkl", "wb") as f:
    pickle.dump(person_names, f)
    pickle.dump(face_embeddings, f)
```

最终我们遍历数据库中的每一个照片, 完成信息的登记流程

## 新照片人脸识别

当相机拍摄到新的人脸时, 我们只需要进行与人脸注册时相同的人脸检测模型的流程, 便能够得到类似的人脸信息编码

```python
def facenet_recognition(image_path):

    global face_embeddings, person_names
    if False:
        image = Image.open(image_path)
        img_face = mtcnn(image)
        img_embedding = resnet(img_face.unsqueeze(0)).detach().numpy()
    else:
        img_embedding = detect_faces_retinaface(image_path).detach().numpy()
    distances = [distance(img_embedding, ref_embedding) for ref_embedding in face_embeddings]
    distances_names = zip(*sorted(zip(distances, person_names)))
    return distances_names
```

其中, 我们可以使用 Euclidean Distance (L2) 来比较不同人脸编码之间的距离, 来作为比较不同人脸编码的差异:

```python

def distance(embeddings1, embeddings2, distance_metric=0):
        # Euclidian distance
        diff = np.subtract(embeddings1, embeddings2)
        dist = np.sum(np.square(diff),1)
    return dist

```


# 基于 `Dlib` 实现的人脸识别框架


TBC

