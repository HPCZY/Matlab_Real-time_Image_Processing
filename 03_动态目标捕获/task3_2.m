clear; close all; clc
    load emo
findme(emo,rp,cp,hp)

function findme(emo,rp,cp,hp)
% ����GUI
Fig = figure('Position',[100,150,980,500]);

Pnl1 = uipanel(Fig,'Position',[0.05,0.17,0.9,0.8]);
Pnl2 = uipanel(Fig,'Position',[0.05,0.05,0.9,0.1]);

Axes1 = axes(Pnl1,'Position',[0,0,1/2,1]);
Axes2 = axes(Pnl1,'Position',[1/2,0,1/2,1]);

Bt = uicontrol(Pnl2,'style','togglebutton','String','�������','Fontsize',16,...
    'Units','normalized','Position',[2/5,0,1/5,1],'Callback',@FaceDetection);
drawnow

Hcamera = [];
Hobj = [];
rows = 0;
cols = 0;
gap = 2;
flag = 0;
faceDetector = vision.CascadeObjectDetector();

% ��ʼ
Camera()
[Face,rp,cp]= drawface(emo,rp,cp,hp);
while 1
%     tic
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
            Px = bboxx(1);
            Py = -bboxx(2);
            Face.XData = cp+Px;
            Face.YData = rp+Py;
            %             imshow(frame,'Parent',Axes3)
            hold(Axes1,'on')
            for i = 1:size(bboxx,1)
                bbox=bboxx(i,:);
                rc=bbox+[-bbox(3)/4,-bbox(4)/4,bbox(3)/2,bbox(4)/2];
                rectangle('Position',rc,...
                    'Curvature',0,...
                    'LineWidth',2,...
                    'LineStyle','--',...
                    'EdgeColor','y','Parent',Axes1)
            end
            hold(Axes1,'off')   
            end
        end
        
        drawnow
    else
        break
    end
%     t = toc;
%     disp(t)
end

    function Camera(~,~)
        if isempty(Hcamera)
            Hobj = videoinput('winvideo',1,'MJPG_640x480');
            Hcamera = preview(Hobj);
            frame = getsnapshot(Hobj);  % ��ȡ֡
            [rows,cols,~] = size(frame);
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

    function [h,rp,cp] = drawface(emo,rp,cp,hp)
        % ���ر���
        mtype = 20;
        siz = 50;
        rp = rp*siz;
        cp = cp*siz;
        % ����
        h = surf(cp,rp,hp,'EdgeAlpha',0,'Parent',Axes2);
        set(h,'CData',emo{mtype},'FaceColor','texturemap');
        
        hold off
        axis equal
        axis([0,cols,-rows,0,0,1])
        axis off
        view([0,0,1])
        set(gca,'looseInset',[0 0 0 0])        
    end

end











