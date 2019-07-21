# Eigenbackgrounds and Logical Combination for Foreground Detection

<p align="center">
<img src = "https://specials-images.forbesimg.com/imageserve/559ebf67e4b05c2c3431c7a4/300x300.jpg?fit=scale&background=000000">
</p>

## Repository Overview 
This repository contains the work done over ENGR484 Senior Capstone Design Project. 
First, the Matlab file contains the combination eigenbackground method discussed to obtaine the foreground masked images.
This method was employed on a database from Trinity College's \\tbos\Projects\Smedley ecology dataset gathered in 2015.
The resulting foreground masks created by employing the combination eigenbackground method on various datasets were compiled
into a dropbox folder containing approximately a total of 600 training images for two classes: humans and animals.
Then, a convolutional neural network was built using Python3 and tensorflow using Google Colab. The ipynb notebook can also be
found in this repository.

<p align = "center">
<img src = "https://user-images.githubusercontent.com/49466466/61164493-a2defc00-a550-11e9-9912-24eef1c71e2c.jpg">
<p>

## Introduction
Camera-traps are stationary, motion-triggered cameras that are secured to trees in the field in order to observe the animal population and biodiversity in the selected area. As the animals pass through the desired area, camera traps are motion triggered to capture short sequences of images. These camera traps are becoming increasingly popular, as they are a cost-effective, non-invasive way of capturing biodiversity data. These image sets typically range in the order of tens of thousands, an dthe task of manually processing these images is extremely time consuming. 

## General Method
The Eigenbackground method uses the eigenvectors of the image data set to perform singular value decomposition and principal component analysis to construct a robust probability density function of the static portions of background. The Eigenbackground is not strictly pixel related, as it takes into account the corresponding pixel values in the form of eigenvectors, and is relatively computationally light. 

### Psuedocode for finding the Eigenbackground

- Reshape each image into a column vector of shape wh x 1, and append each image in sequence such that a sequence of images is of shape wh x N, where N is the number of image frames in the sequence
- Subtract the mean image (column vector) from each image in the sequence above, creating a normalized image vector X
- Apply singular value decomposition to X such that X = USV^t, where U is an orthogonal matrix containing the left eigenvectors of the covariance matrix of XX^t
- Take the first R ranks of U (now calling it U_r), such that it contains the majority of the covariance explained by the eigenvectors
- The princial component p is calculated by taking the transpose of U_r and multiplying it to (y-m) where y is the current image and m is the mean image.
- Find the projected image of each image now by multiplying U_r by p, and adding m.
- Take each image subtracted by its own subtracted image, then threshold the absolute value of the difference.
All of these steps can be done iteratively throughout the entire image sequence.

### Reducing False Negative Detection

The foreground masks of resulting from the Eigenbackground images will then be further filtered using a logical combination with its two most adjacent masks, further reducing the false positive rate of the detection system. The following flowchart explains the process:

<p align="center">
<img src = "https://user-images.githubusercontent.com/49466466/61576394-9b9d8c80-ab14-11e9-816f-6179690d48fe.png">
</p>

### Convolutional Neural Network

Since each sequence of images will now produce a masked image where everything but the foreground is black (pixel value 0), we can use this to build a training set for our CNN. The CNN will take the images and learn through convolving and maxpooling, the higher level features to distinguish between the 2 classes, humans vs animals. For our convolutional neural network, we used 5 layers, each with 4 convolutional filters (size 3x3) (for demonstrative purposes), ReLu activation function, 2x2 Maxpooling, 512 neuron hidden layer, and finally a sigmoid activation function for the final neuron. The loss function we used was the binary cross entropy function. 

An example of the final layer of convolutional filters result in the following expression of higher level features:

<p align="center">
<img src = "https://user-images.githubusercontent.com/49466466/61576476-79f0d500-ab15-11e9-90c3-ae9a935a94ce.png">
</p>


## Quick Results
* Main Assumption of thie method is that the foreground animal(s) move significantly enough in terms of pixel distances that they do not get filtered out by the logical masks.
* The proposed Eigenbackground-Combination method has a 90+% detection accuracy rate. 
* The Convolutional Neural Network will vary it its capacity given different values for the number of neurons, number of hidden layers, etc.

## Future Work
More data sets will have to be gathered to make an unbiased testing dataset for the CNN. Also, more methods of reducing the false positive rate while retaining the true negative rate should be explored. 
