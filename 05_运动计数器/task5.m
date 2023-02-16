clear; close all; clc

findme()

function findme()

% ����GUI
Fig = figure('Position',[500,450,980,500]);

Pnl1 = uipanel(Fig,'Position',[0.05,0.17,0.9,0.8]);
Pnl2 = uipanel(Fig,'Position',[0.05,0.05,0.9,0.1]);

Axes1 = axes(Pnl1,'Position',[0,0,1/2,1]);
Axes2 = axes(Pnl1,'Position',[1/2,0,1/2,1]);

Bt = uicontrol(Pnl2,'style','togglebutton','String','����Ŀ�겢��ʼ����','Fontsize',16,...
    'Units','normalized','Position',[0,0,0.5,1],'Callback',@LockTarget);
Txt = uicontrol(Pnl2,'style','text','String',[],'Fontsize',16,...
    'Units','normalized','Position',[0.5,0,0.5,1]);
drawnow

% ��������ͷ
Hcamera = [];
Hobj = [];
if isempty(Hcamera)
    Hobj = videoinput('winvideo',1,'MJPG_640x480');
    Hcamera = preview(Hobj);
    frame = getsnapshot(Hobj);  % ��ȡ֡
end

% ��ʼ������
flag = 0;
tracker = vision.PointTracker('MaxBidirectionalError',1);
gap = 1;
objectRegion = [0,0,0,0];
objFrame = [];
points = [];

% ��ʼ������
rows = 0;
bodyPosition = [];
time = 0;
H = fspecial('average',[1,5]);
MPP = 100;
count = 0;

pause(5)
LockTarget()

% ��ʼ
while 1
    if ishandle(Hcamera)
        % ��ȡӰ��
        frame = getsnapshot(Hobj);  % ��ȡ֡
        if flag
            % ���
            point = face(frame);
            imshow(frame,'Parent',Axes1)
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
        bodyPosition = [];
        time = 0;
        count = 0;
        set(Txt,'String',num2str(count))
        % ������
        frame = frame(1:gap:end,1:gap:end,:);
        objFrame = frame;
        % ȷ��Ŀ��λ��
        [x,y,~] = ginput(2);
        objectRegion = [min(x),min(y),max(x)-min(x),max(y)-min(y)]/gap;
        % ���������
        points = detectMinEigenFeatures(rgb2gray(frame),'ROI',objectRegion);        
        % ��ʼ��������
        release(tracker)
        initialize(tracker, points.Location, frame);
        flag = 1;
        rows = size(frame,1);
        bodyPosition = ones(1,30*3600)*(rows-mean(points.Location(:,2),1));        
    end

    function point = face(frame)
        % ������
        frame = frame(1:gap:end,1:gap:end,:);
        % ׷��
        [point,validity] = tracker(frame);
        point = point(validity,:);
        % ����Ŀ��
        if size(point,1)<10
            release(tracker)
            initialize(tracker, points.Location, objFrame);
            [point,validity] = tracker(frame);
            point = point(validity,:);
        end
        % ��������
        point = point*gap;
        
        time = time+1;
        bodyPosition(time) = rows-mean(point(:,2),1);
        tmp = imfilter(bodyPosition(1:time+10),H,'replicate','same');
        [pks, locs] = findpeaks(tmp, 'MinPeakProminence', MPP); 
        count = length(pks);
        
        % ��ʾ
        plot(Axes2,tmp,'b-')
        hold(Axes2,'on')
        plot(Axes2,locs,pks,'r<')
        hold(Axes2,'off')
        axis(Axes2,[0,time+30,0,rows])
        set(Txt,'String',num2str(count))
    end

end











