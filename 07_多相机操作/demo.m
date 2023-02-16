clear; close all; clc

% ���ɶ���ͬ������
obj1 = videoinput('winvideo',1,'MJPG_640x480');
obj2 = videoinput('winvideo',2,'MJPG_640x480');
obj3 = ipcam('http://192.168.3.45:4747/video/mjpg.cgi');
obj4 = ipcam('http://192.168.3.38:4747/video/mjpg.cgi');

h1 = preview(obj1);
h2 = preview(obj2);
h3 = preview(obj3);
h4 = preview(obj4);

%% ʵʱ��ʾ������
figure('Position',[800,400,1000,500])
while ishandle(h1)
    tic
    % ��ȡӰ��
    frame1 = getsnapshot(obj1);  % ��ȡ֡
    frame2 = getsnapshot(obj2);  % ��ȡ֡
    frame3 = snapshot(obj3);  % ��ȡ֡  
    frame4 = snapshot(obj4);  % ��ȡ֡ 
    
    % ��ʾ
    subplot(221),imshow(frame1)
    subplot(222),imshow(frame2)
    subplot(223),imshow(frame3)
    subplot(224),imshow(frame4)
    drawnow
    t = toc;
    disp(round(1/t))
end
