clear; close all; clc

MosaicPlease()

function MosaicPlease()

% 创建GUI
Fig = figure('Position',[300,350,700,600]);
% 回调
set(Fig,'WindowButtonDownFcn',@ButtonDown);
set(Fig,'WindowButtonUpFcn',@ButtonUp);


Pnl1 = uipanel(Fig,'Position',[0.05,0.17,0.9,0.8]);
Pnl2 = uipanel(Fig,'Position',[0.05,0.05,0.9,0.1]);

Axes1 = axes(Pnl1,'Position',[0,0,1,1]);

Bt = uicontrol(Pnl2,'style','togglebutton','String','给目标打码','Fontsize',16,...
    'Units','normalized','Position',[0,0,0.5,1],'Callback',@Choose);
drawnow

% 开启摄像头
Hcamera = [];
Hobj = [];
if isempty(Hcamera)
    Hobj = videoinput('winvideo',2,'MJPG_640x480');
    Hcamera = preview(Hobj);
    frame = getsnapshot(Hobj);  % 获取帧
end

% 初始化参数
[rows,cols,~] = size(frame);
flag = 0;
tracker = vision.PointTracker('MaxBidirectionalError',1);
objectRegion = [0,0,0,0];
objFrame = [];
points = [];

% 记录鼠标位置
p1 = [];
p2 = [];
OC = 0;
OR = 0;
tmp = [];

% 打码参数
H = fspecial('average',20);

% 开始
while 1
    if ishandle(Hcamera)
        % 获取影像
        frame = getsnapshot(Hobj);  % 获取帧
        if flag==2
            % 检测
            Mosaic(frame);
        elseif flag==1
            %等着选目标
        else
            % 普通显示
            imshow(frame,'Parent',Axes1)
        end
        drawnow
    else
        break
    end
end

    function Choose(~,~)
        flag = 1;
    end

    function LockTarget(~,~)
        % 降采样
        objFrame = frame;
        % 确定目标位置
        objectRegion = [OC(1)-OR,OC(2)-OR,2*OR,2*OR];
        % 检测特征点
        points = detectMinEigenFeatures(rgb2gray(frame),'ROI',objectRegion);
        % 初始化跟踪器
        release(tracker)
        initialize(tracker, points.Location, frame);
        flag = 1;
        OC = mean(points.Location,1);
        flag = 2;
    end


    function Mosaic(frame)
        % 追踪
        [point,validity] = tracker(frame);
        point = point(validity,:);
        % 更新目标
        if size(point,1)<10
            release(tracker)
            initialize(tracker, points.Location, objFrame);
            [point,validity] = tracker(frame);
            point = point(validity,:);
        end
        OC = round(mean(point,1));
        
        % 显示
        newframe = imfilter(frame,H);
        % 防止超出屏幕
        a = max(1,OC(2)-OR);
        b = min(rows,OC(2)+OR);
        c = max(1,OC(1)-OR);
        d = min(cols,OC(1)+OR);
        
        frame(a:b,c:d,:) = newframe(a:b,c:d,:);
        imshow(frame,'Parent',Axes1)

        
    end


%% 鼠标组
    function ButtonDown(~,~)
        if flag==1
        cp = get(gca,'currentpoint');
        p1 = [cp(1,1),cp(1,2)];
        hold(Axes1,'on')
        tmp = plot(p1(1),p1(2),'r.','Parent',Axes1);
        end
    end

    function ButtonUp(~,~)
        if flag==1
            cp = get(gca,'currentpoint');
            delete(tmp)
            p2 = [cp(1,1),cp(1,2)];
            OR = round(norm(p1-p2));
            [cx,cy] = DrawCircle(p1,OR); % 基本结构
            plot(cx,cy,'LineWidth',5,'Parent',Axes1); 
            hold(Axes1,'off')
            drawnow
            OC = p1;
            LockTarget()
        end
    end

end



%% 子函数
% 生成圆形
function [cx,cy] = DrawCircle(c,r)
t = 0:pi/32:2*pi;
cx = r*cos(t')+c(1);
cy = r*sin(t')+c(2);
end

