# Eigenbackgrounds and Logical Combination for Foreground Detection

![picture alt](https://specials-images.forbesimg.com/imageserve/559ebf67e4b05c2c3431c7a4/300x300.jpg?fit=scale&background=000000)

## Repository Overview 
This repository contains the work done over ENGR484 Senior Capstone Design Project. 
First, the Matlab file contains the combination eigenbackground method discussed to obtaine the foreground masked images.
This method was employed on a database from Trinity College's \\tbos\Projects\Smedley ecology dataset gathered in 2015.
The resulting foreground masks created by employed the combination eigenbackground method on various datasets were compiled
into a dropbox folder containing approximately a total of 600 training images for two classes: humans and animals.
Then, a convolutional neural network was built using Python3 and tensorflow using Google Colab. The ipynb notebook can also be
found in this repository.

## Introduction
Camera-traps are stationary, motion-triggered cameras that are secured to trees in the field in order to observe the animal population and biodiversity in the selected area. As the animals pass through the desired area, camera traps are motion triggered to capture short sequences of images. These camera traps are becoming increasingly popular, as they are a cost-effective, non-invasive way of capturing biodiversity data. These image sets typically range in the order of tens of thousands, an dthe task of manually processing these images is extremely time consuming. 

## General Method
The Eigenbackground method uses the eigenvectors of the image data set to perform singular value decomposition and principal component analysis to construct a robust probability density function of the static portions of background. The Eigenbackground is not strictly pixel related, as it takes into account the corresponding pixel values in the form of eigenvectors, and is relatively computationally light. The foreground masks of resulting from the Eigenbackground images will then be further filtered using a logical combination with its two most adjacent masks, further reducing the false positive rate of the detection system. 

## Quick Results
* The proposed Eigenbackground-Combination method has a 90+% detection accuracy rate. 
* The Convolutional Neural Network will vary it its capacity given different values for the number of neurons, number of hidden layers, etc.

## Future Work
More data sets will have to be gathered to make an unbiased testing dataset for the CNN. Also, more methods of reducing the false positive rate while retaining the true negative rate should be explored. 
