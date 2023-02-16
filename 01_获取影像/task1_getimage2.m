clear; close all; clc

%% 配置java
pos = [20 40 500 400]; % [左 上 宽 高]
row = pos(4);
col = pos(3);
robot = java.awt.Robot();
rect = java.awt.Rectangle(pos(1),pos(2),pos(3),pos(4));

%% 实时显示（处理）
figure('Position',[800,400,1000,500])
while 1
    tic
    % 获取影像
    cap = robot.createScreenCapture(rect);
    % 转换格式
    rgb = typecast(cap.getRGB(0,0,col,row,[],0,cap.getWidth),'uint8');
    rgb = reshape(rgb,[4,row*col])';
    frame = permute(reshape(rgb(:,3:-1:1),[col,row,3]),[2,1,3]);
    % 一顿疯狂处理
    img = rgb2gray(frame);
    % 显示
    subplot(121),imshow(frame)
    subplot(122),imshow(img)
    drawnow
    t = toc;
    disp(round(1/t))
end


