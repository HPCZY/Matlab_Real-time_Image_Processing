clear; close all; clc

%% ʵʱ��ʾ������
% ���ɶ��󲢿��������
obj = videoinput('winvideo',1,'MJPG_640x480'); 
h1 = preview(obj);
h2 = figure('Position',[100,50,1680,800]);

% ��ʼ
while ishandle(h1)&&ishandle(h2)
    tic
    % ��ȡӰ��
    frame = getsnapshot(obj);  % ��ȡ֡
    frame = im2double(frame(:,1+80:end-80,:));
    
    % һ�ٷ����
    % --------------------------------
    img1 = DoSomethingCrazy1(frame);
    img2 = DoSomethingCrazy2(frame);
    img3 = frame.*img2*2;
    % --------------------------------    
    img = cat(2,img1,cat(3,img2,img2,img2),img3);
    % ����
    imshow(img)
    drawnow

    t = toc;
    disp(round(1/t))
end


function ed = DoSomethingCrazy1(frame)
% ��һ����ɫ�ռ�
gray = rgb2gray(frame);
mask = double(gray>0.05);
imsum = sqrt(sum(frame.^2,3));
ed = frame./imsum.*mask;
end

function ed = DoSomethingCrazy2(frame)
% �Ҷȱ�Ե
core1 = [1,1,1;0,0,0;-1,-1,-1;];
core2 = [1,1,0;1,0,-1;0,-1,-1;];
frame = rgb2gray(frame);
im1 = imfilter(frame,core1);
im2 = imfilter(frame,core1');
im3 = imfilter(frame,core2);
im4 = imfilter(frame,core2');
ed = max(abs(cat(3,im1,im2,im3,im4)),[],3);
end