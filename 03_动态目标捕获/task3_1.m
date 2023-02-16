clear; close all; clc

findme()

function findme()

% ����GUI
Fig = figure('Position',[100,150,980,500]);

Pnl1 = uipanel(Fig,'Position',[0.05,0.17,0.9,0.8]);
Pnl2 = uipanel(Fig,'Position',[0.05,0.05,0.9,0.1]);

Axes1 = axes(Pnl1,'Position',[0,0,1/2,1]);
Axes2 = axes(Pnl1,'Position',[1/2,0,1/2,1]);

Bt = uicontrol(Pnl2,'style','togglebutton','String','�������','Fontsize',16,...
    'Units','normalized','Position',[2/5,0,1/5,1],'Callback',@FaceDetection);
drawnow

% ��������ͷ
Hcamera = [];
Hobj = [];
if isempty(Hcamera)
    Hobj = videoinput('winvideo',1,'MJPG_640x480');
    Hcamera = preview(Hobj);
    frame = getsnapshot(Hobj);  % ��ȡ֡
    [rows,cols,~] = size(frame);
end

% ����ʶ��
flag = 0;
faceDetector = vision.CascadeObjectDetector();
gap = 2;

% ��
[Face,rp,cp] = drawface();

% ��ʼ
while 1
    if ishandle(Hcamera)
        % ��ȡӰ��
        frame = getsnapshot(Hobj);  % ��ȡ֡
        frame = im2double(frame);
        % ��ʾ
        imshow(frame,'Parent',Axes1)
        % ���
        if flag
            bboxx = face(frame);
            if ~isempty(bboxx)
                Px = bboxx(1,1);
                Py = -bboxx(1,2);
                Face.XData = Px;
                Face.YData = Py;
            end
            hold(Axes1,'on')
            for i = 1:size(bboxx,1)
                bbox = bboxx(i,:);
                rc = bbox+[-bbox(3)/4,-bbox(4)/4,bbox(3)/2,bbox(4)/2];
                rectangle('Position',rc,'Curvature',0,...
                    'LineWidth',2,'LineStyle','--',...
                    'EdgeColor','y','Parent',Axes1)
            end
            hold(Axes1,'off')
        end
        drawnow
    else
        break
    end
end

    function FaceDetection(~,~)
        flag = get(Bt,'Value');
    end

    function bboxx = face(frame)
        frame = frame(1:gap:end,1:gap:end,:);
        bboxx = step(faceDetector, frame);
        bboxx = bboxx*gap;
    end

    function [h,rp,cp] = drawface()        
        rp = cols/2;
        cp = -rows/2;
        % ����
        h = plot(rp,cp,'ro','MarkerSize', 35);
        hold off
        axis equal
        axis([0,cols,-rows,0,0,1])
        axis off
        view([0,0,1])
        set(gca,'looseInset',[0 0 0 0])
    end

end











