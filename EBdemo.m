clear all
close all
clc

%using this method, if a foreground object stays stationary or remain in
%similar positions in consecutive frames, the system will not detect its
%movement in the final FG mask. This system will, however, reduce total
%noise caused by background changes, due to the consecutive frame update
%system.


%designate a folder with desired image dataset to work on
folder = 'C:\Users\Justin\Desktop\capstone\deerFG';
%use '*' to call all files within the folder of jpg type
filePattern = fullfile(folder, '*.jpg');
f=dir(filePattern);
files={f.name};
N = numel(files); %# of images in dataset

%Reading, border-cropping, and resizing the images in the dataset
%this loads the read images into the working directory
for k= 1: N
    
    fullFileName = fullfile(folder, files{k});
    X1 = imread(fullFileName);
    X1BorderCrop = imcrop(X1,[17.5 47.5 2025 1410]);
    Xresized = imresize( X1BorderCrop , [300 300]); %resizing for calculation purposes
    %saves renamed files to 'colorImages' folder, our working folder 
    imwrite(Xresized,strcat('C:\Users\Justin\Desktop\capstone\colorImages','\',sprintf('%03d',k),'.jpg'),'jpg');
    %must be in 001..010..019...030.jpg format for eigen calculations to
    %work
    showSeq(:,:,:,k) = Xresized; %for ppt purposes, FD purposes
end

MedianImage = median(showSeq,4); %construct median image
MedianImage = rgb2gray(MedianImage); %convert median image to grayscale
backMed = medfilt2(MedianImage, [5 5]);%median filtered background image

%dataset related values%assign according to working directory  values
training_number = numel(files);
%make this equal to total if desired. can be arbitrary, 60% dataset, etc...
total = numel(files); %fixed number, same as N above
imgsizeX= size(Xresized, 1); %originally 1536 (resize and check before inputting here)/// or just use this format
imgsizeY= size(Xresized, 2); %originally 2048 (for comp. mem. reasons, img's resized)


for i = 1: N %i=1:training_number
    name0 = num2str(i);
    %disp (name);
    number='000';
    name0 =[number(1:(3-length(name0))) name0];
    name0 = [name0 '.jpg'];
    disp (['Reading Training File ' name0]);
    read = imread(name0);
    read = rgb2gray(read);
    read = im2double(read);
    b(i,:) = read(:); %row vector of images
    ImSeq(:,:,i) = read;
    %X(:,i) = reshape(read,imgsizeY*imgsizeX,1); %column vector of images
end

c= b'; %transpose to a column vector
mean = sum(b)/N; %calculating mean image
meanim= reshape(mean, imgsizeX, imgsizeY); %reshaped mean image to w*h dim.

%mean normalized image vectors are then put as column of a matrix X
for i = 1 : N
    X(:,i) = c(:,i) - mean';
    fprintf('Remaining Images: %d\n', numel(files) -i);
end

%calculate SVD  (taking svds to save memory--take only 6 columns)
%matlab command svds() takes 6 largest singular values, saves comp. mem.
[U, S, V] = svds(X); 
%U,V are orthogonal matrices and S is a diagonal matrix 
%with singular values, in decreasing order, in its diagonal.
Ur = U(:,2); 
%taking the r=2, where r is the rank of the SVD matrix U
%chaning the range or r from 2~6 has minimal effect, just computationally
%more effective to use r=2

%this here is actually redundant because i already have variables
%imgsizeX and imgsizeY, but for clarity's sake, i will keep the following
%two lines of code, to be used in the following loop
size_of_img = ImSeq(:,:,1); %take first image
[rows, cols] = size(size_of_img); %image size calculation again

T = graythresh(MedianImage)/2; %arbitrary threshold value

%using a loop from 1:N such that:
%we do PCA through eigenvector from SVD to find projected image
%diff in projected image and input image
%thresholded difference image
for i = 1:N
    input= ImSeq(:,:,i);
    input= input(:);
    showinput= reshape(input,imgsizeX,imgsizeY);
    inputSource(:,:,i)= showinput; %for loop below for final mask overlay
    
    p = Ur'*(input- mean');
    y_bar= Ur*p + mean'; %projecting the image onto the reduced subspace 
    im = reshape(y_bar , rows, cols);
    
    diff= abs(input - y_bar);
    diffre= reshape(diff, rows, cols);

    diffThresholded = diff > T;
    Tdiff = reshape(diffThresholded, rows, cols);

    showInputMask= reshape(input, rows, cols);
    showInputMask(Tdiff<1)=0;
    eigenMASK(:,:,i) = logical(showInputMask);
    %end of eigenbackground FG mask (binary)
    windowWidth = 25;
    blurredImage = conv2(double(eigenMASK(:,:,i)), ones(windowWidth)/windowWidth^2, 'same');
    % Threshold again using midpoint of the blur to smooth the image
    eigenMASK(:,:,i) = blurredImage > 0.5;
    
    %obtain mask using FD median image 
    MtestIm= medfilt2( rgb2gray(showSeq(:,:,:,i)), [5 5]); 
    diffImage = abs(double(MtestIm) - double(backMed)); 
    animalMask = diffImage >  (T*255); % threshold value
    se = strel('disk',10,4);
    animalMask = imdilate(animalMask,se);%dilate logical mask
    maskedImage = MtestIm; % Initialize.
    maskedImage(animalMask < 1) = 0; 
    medianFDMASK(:,:,i) = logical(maskedImage);
    %end of FD median image mask method
    blurredMedImage = conv2(double(medianFDMASK(:,:,i)), ones(windowWidth)/windowWidth^2, 'same');
    %Threshold again. 0.5 since it is the midpoint value of the "blur"
    medianFDMASK(:,:,i) = blurredMedImage > 0.5;
    medianFDMASK(:,:,i) =  imfill(medianFDMASK(:,:,i), 'holes');
    medianFDMASK(:,:,i) = bwareafilt(medianFDMASK(:,:,i), [400, inf]);
end

%initializing matrices for combo masks
FPSup(:,:,1)= eigenMASK(:,:,1)- (eigenMASK(:,:,1) & eigenMASK(:,:,2) & eigenMASK(:,:,3));
FPSup(:,:,N) = eigenMASK(:,:,N) - (eigenMASK(:,:,N-1) & eigenMASK(:,:,N-2) & eigenMASK(:,:,N));
finalCOMBO(:,:,1)= FPSup(:,:,1) | medianFDMASK(:,:,1);
finalCOMBO(:,:,N)= FPSup(:,:,N) | medianFDMASK(:,:,N);

for i = 2:N-1
    FPSup(:,:,i) = eigenMASK(:,:,i) - (eigenMASK(:,:,i+1) & eigenMASK(:,:,i) & eigenMASK(:,:,i-1));
    %using logic AND operator and Frame Difference, suppress false 
    %positives of eigenbackground FG mask @ longer datasets
    finalCOMBO(:,:,i) = FPSup(:,:,i) | medianFDMASK(:,:,i);
    %create the final combo FG mask process as proposed,
    %using logic OR operator
end

for i = 1:N
    %process combo mask to remove "noise" and create final mask
    finalPROC(:,:,i) =  imfill(finalCOMBO(:,:,i), 'holes');
    finalPROC(:,:,i) = bwareafilt(finalPROC(:,:,i), [300, inf]);
    finalDIL = finalPROC(:,:,i);
    
    %initialize input imgs to overlay mask
    FINALinput= ImSeq(:,:,i);
    MASKinput= reshape(FINALinput,imgsizeX,imgsizeY); %initializing
    MASKinput(finalDIL <1 ) = 0 ; %using combo mask to get final fg detection scheme
    %writing the final mask as a new jpg file
    imwrite(MASKinput,strcat('C:\Users\Justin\Desktop\capstone\colorImages','\','dwdw',int2str(i),'.jpg'),'jpg'); 
    
end


