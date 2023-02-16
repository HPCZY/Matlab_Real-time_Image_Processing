clear; close all; clc
    load emo
findme(emo,rp,cp,hp)

function findme(emo,rp,cp,hp)
% 创建GUI
Fig = figure('Position',[100,150,980,500]);

Pnl1 = uipanel(Fig,'Position',[0.05,0.17,0.9,0.8]);
Pnl2 = uipanel(Fig,'Position',[0.05,0.05,0.9,0.1]);

Axes1 = axes(Pnl1,'Position',[0,0,1/2,1]);
Axes2 = axes(Pnl1,'Position',[1/2,0,1/2,1]);

Bt = uicontrol(Pnl2,'style','togglebutton','String','人脸检测','Fontsize',16,...
    'Units','normalized','Position',[2/5,0,1/5,1],'Callback',@FaceDetection);
drawnow

Hcamera = [];
Hobj = [];
rows = 0;
cols = 0;
gap = 2;
flag = 0;
faceDetector = vision.CascadeObjectDetector();

% 开始
Camera()
[Face,rp,cp]= drawface(emo,rp,cp,hp);
while 1
%     tic
    if ishandle(Hcamera)
        
        % 获取影像
        frame = getsnapshot(Hobj);  % 获取帧
        frame = im2double(frame);
        % 显示
        imshow(frame,'Parent',Axes1)
        
        % 监测
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
            frame = getsnapshot(Hobj);  % 获取帧
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
        % 加载表情
        mtype = 20;
        siz = 50;
        rp = rp*siz;
        cp = cp*siz;
        % 绘制
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











