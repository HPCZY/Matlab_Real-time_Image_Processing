clear; close all; clc

%% 配置摄像头
% -----------------------------------------
% 查看适配器
disp(imaqhwinfo)
% 查看设备及其支持的格式
info = imaqhwinfo('winvideo');
disp(info.DeviceInfo.SupportedFormats)
% --------你要是知道就不要运行这两句-------

% 生成对象并同步画面
obj = videoinput('winvideo',1,'MJPG_640x480');
h = preview(obj);

%% 实时显示（处理）
figure('Position',[800,400,1000,500])
while ishandle(h)
    tic
    % 获取影像
    frame = getsnapshot(obj);  % 获取帧
    % 一顿疯狂处理
    img = rgb2gray(frame);
    % 显示
    subplot(121),imshow(frame)
    subplot(122),imshow(img)
    drawnow
    t = toc;
    disp(round(1/t))
end

