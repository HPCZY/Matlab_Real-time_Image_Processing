clear; close all; clc

findme()

function findme()

% 创建GUI
Fig = figure('Position',[500,450,980,500]);

Pnl1 = uipanel(Fig,'Position',[0.05,0.17,0.9,0.8]);
Pnl2 = uipanel(Fig,'Position',[0.05,0.05,0.9,0.1]);

Axes1 = axes(Pnl1,'Position',[0,0,1/2,1]);
Axes2 = axes(Pnl1,'Position',[1/2,0,1/2,1]);

Bt = uicontrol(Pnl2,'style','togglebutton','String','锁定目标','Fontsize',16,...
    'Units','normalized','Position',[2/5,0,1/5,1],'Callback',@LockTarget);
drawnow

% 开启摄像头
Hcamera = [];
Hobj = [];
if isempty(Hcamera)
    Hobj = videoinput('winvideo',1,'MJPG_640x480');
    Hcamera = preview(Hobj);
    frame = getsnapshot(Hobj);  % 获取帧
end

% 人脸识别
flag = 0;
tracker = vision.PointTracker('MaxBidirectionalError',1);
gap = 1;
objectRegion = [0,0,0,0];
objFrame = [];
points = [];


% 开始
while 1
    if ishandle(Hcamera)
        % 获取影像
        frame = getsnapshot(Hobj);  % 获取帧
        frame = im2double(frame);
        if flag
            % 检测
            point = face(frame);
            objimg = insertMarker(frame,point,'+','Color','green');
            imshow(objimg,'Parent',Axes1)
        else
            % 普通显示
            imshow(frame,'Parent',Axes1)
        end
        drawnow
    else
        break
    end
end

    function LockTarget(~,~)
        % 降采样
        frame = frame(1:gap:end,1:gap:end,:);
        objFrame = frame;
        % 确定目标位置
        [x,y,~] = ginput(2);
        objectRegion = [min(x),min(y),max(x)-min(x),max(y)-min(y)]/gap;
        % 检测特征点
        points = detectMinEigenFeatures(rgb2gray(frame),'ROI',objectRegion);
        pointImage = insertMarker(frame, points.Location,'+','Color','green');
        imshow(pointImage,'Parent',Axes2)
        % 初始化跟踪器
        release(tracker)
        initialize(tracker, points.Location, frame);
        flag = 1;
    end

    function point = face(frame)
        % 降采样
        frame = frame(1:gap:end,1:gap:end,:);
        % 追踪
        [point,validity] = tracker(frame);
        point = point(validity,:);
        % 更新目标
        if size(point,1)<20
            % 方法一
%             x = point(:,1);
%             y = point(:,2);
%             objectRegion = [min(x),min(y),max(x)-min(x),max(y)-min(y)];
%             points = detectMinEigenFeatures(rgb2gray(frame),'ROI',objectRegion);
            % 方法二
            release(tracker)
            initialize(tracker, points.Location, objFrame);
            [point,validity] = tracker(frame);
            point = point(validity,:);
        end
        % 反算坐标
        point = point*gap;
    end

end











