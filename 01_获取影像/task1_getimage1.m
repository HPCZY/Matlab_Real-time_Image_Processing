clear; close all; clc

%% ��������ͷ
% -----------------------------------------
% �鿴������
disp(imaqhwinfo)
% �鿴�豸����֧�ֵĸ�ʽ
info = imaqhwinfo('winvideo');
disp(info.DeviceInfo.SupportedFormats)
% --------��Ҫ��֪���Ͳ�Ҫ����������-------

% ���ɶ���ͬ������
obj = videoinput('winvideo',1,'MJPG_640x480');
h = preview(obj);

%% ʵʱ��ʾ������
figure('Position',[800,400,1000,500])
while ishandle(h)
    tic
    % ��ȡӰ��
    frame = getsnapshot(obj);  % ��ȡ֡
    % һ�ٷ����
    img = rgb2gray(frame);
    % ��ʾ
    subplot(121),imshow(frame)
    subplot(122),imshow(img)
    drawnow
    t = toc;
    disp(round(1/t))
end

