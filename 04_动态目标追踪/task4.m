clear; close all; clc

findme()

function findme()

% ����GUI
Fig = figure('Position',[500,450,980,500]);

Pnl1 = uipanel(Fig,'Position',[0.05,0.17,0.9,0.8]);
Pnl2 = uipanel(Fig,'Position',[0.05,0.05,0.9,0.1]);

Axes1 = axes(Pnl1,'Position',[0,0,1/2,1]);
Axes2 = axes(Pnl1,'Position',[1/2,0,1/2,1]);

Bt = uicontrol(Pnl2,'style','togglebutton','String','����Ŀ��','Fontsize',16,...
    'Units','normalized','Position',[2/5,0,1/5,1],'Callback',@LockTarget);
drawnow

% ��������ͷ
Hcamera = [];
Hobj = [];
if isempty(Hcamera)
    Hobj = videoinput('winvideo',1,'MJPG_640x480');
    Hcamera = preview(Hobj);
    frame = getsnapshot(Hobj);  % ��ȡ֡
end

% ����ʶ��
flag = 0;
tracker = vision.PointTracker('MaxBidirectionalError',1);
gap = 1;
objectRegion = [0,0,0,0];
objFrame = [];
points = [];


% ��ʼ
while 1
    if ishandle(Hcamera)
        % ��ȡӰ��
        frame = getsnapshot(Hobj);  % ��ȡ֡
        frame = im2double(frame);
        if flag
            % ���
            point = face(frame);
            objimg = insertMarker(frame,point,'+','Color','green');
            imshow(objimg,'Parent',Axes1)
        else
            % ��ͨ��ʾ
            imshow(frame,'Parent',Axes1)
        end
        drawnow
    else
        break
    end
end

    function LockTarget(~,~)
        % ������
        frame = frame(1:gap:end,1:gap:end,:);
        objFrame = frame;
        % ȷ��Ŀ��λ��
        [x,y,~] = ginput(2);
        objectRegion = [min(x),min(y),max(x)-min(x),max(y)-min(y)]/gap;
        % ���������
        points = detectMinEigenFeatures(rgb2gray(frame),'ROI',objectRegion);
        pointImage = insertMarker(frame, points.Location,'+','Color','green');
        imshow(pointImage,'Parent',Axes2)
        % ��ʼ��������
        release(tracker)
        initialize(tracker, points.Location, frame);
        flag = 1;
    end

    function point = face(frame)
        % ������
        frame = frame(1:gap:end,1:gap:end,:);
        % ׷��
        [point,validity] = tracker(frame);
        point = point(validity,:);
        % ����Ŀ��
        if size(point,1)<20
            % ����һ
%             x = point(:,1);
%             y = point(:,2);
%             objectRegion = [min(x),min(y),max(x)-min(x),max(y)-min(y)];
%             points = detectMinEigenFeatures(rgb2gray(frame),'ROI',objectRegion);
            % ������
            release(tracker)
            initialize(tracker, points.Location, objFrame);
            [point,validity] = tracker(frame);
            point = point(validity,:);
        end
        % ��������
        point = point*gap;
    end

end











