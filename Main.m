function Main
% Heart ventricles pixel tracking by Arash Rabbani, rabarash@yahoo.com
close all
ES=12; % End of systole time frame
opt.X=[.5,9]; % tracking options [Gaussian filter sigma, median filter size]
load('M.mat') % Load the raw cine MRI video of the heart with the size of [216 256 10 30], in which two first are image dimentions, the third is slice location and the forth is time frames
load('B.mat') % Load the segmented mask at the first time frame (approximately End diastole)
% Source of the raw and segmented data is ACDC challenge: https://acdc.creatis.insa-lyon.fr/
SL=4; % Select a short axis slice of the heart image
Lab2=track(B,M,ES,SL,opt); % forward tracking (refer to the paper)
Lab2_=trackback(B,M,ES,SL,opt); % backward tracking (refer to the paper)
close all; 
disp("All time frames are saved in Export directory." )
make_video_gif
disp("Final tracking result is saved in a gif video named Final.gif")
end
function Lab2=trackback(Lab,M,ES,SL,opt)
B=Lab;
B=B(:,:,SL);
BB=B;
FN=size(M,4);
for K=FN:-1:ES
    disp(['Processing time frame ' num2str(K)])
    A2=double(M(:,:,SL,K));
    W=superpixels(imgaussfilt(A2,opt.X(1)),7000,'Compactness',5,'Method','slic0','NumIterations',15);
    R=regionprops(W,BB,'PixelValues');
    Ind=zeros(numel(R),1);
    for J=1:numel(R)
        Ind(J)=mode(R(J).PixelValues);
    end
    B2=replace(W,[1:numel(R)],Ind);
    B2=medfilt2(B2,[opt.X(2),opt.X(2)]);
    clf; imagesc(cropper(B2)); CM=cm(); CM=[CM ;1-[.2,0,.35]]; colormap(CM); axis off equal; colorbar off; drawnow;
    bound=lab2edge(B2);
    printx(['Export/Frame_r' num2str(K) '.png']);
    t1=cropper(bound);
    t2=cropper(A2);
    CM2=bone(1024); CM2(1,:)=CM(3,:); clf; imagesc(t2.*(1-t1)); colormap(CM2); colorbar off; axis off; axis equal;
    printx(['Export/Frame_s' num2str(K) '.png']);
    BB=B2;
end
Lab2=BB;
end
function [A]=trim(A,tri)
if ndims(A)==3
    A=A(tri+1:end-tri,tri+1:end-tri,tri+1:end-tri);
end
if ndims(A)==2
    A=A(tri+1:end-tri,tri+1:end-tri);
end
end
function CM=cm()
% colormap
CM=[0.2812,0.187878,0.324064;0.28627,0.5450980,0.3411764;0.68199643,0.802495,0.2128342];
end
function []=printx(Name)
set(gca, 'units', 'normalized');
Tight = get(gca, 'TightInset');
NewPos = [Tight(1) Tight(2) 1-Tight(1)-Tight(3) 1-Tight(2)-Tight(4)];
set(gca, 'Position', NewPos);
print([Name],'-dpng','-r300');
end
function Lab2=track(Lab,M,ES,SL,opt)
B=Lab;
B=B(:,:,SL);
BB=B;
for K=2:ES
    disp(['Processing time frame ' num2str(K)])
    A2=double(M(:,:,SL,K));
    W=superpixels(imgaussfilt(A2,opt.X(1)),7000,'Compactness',5,'Method','slic0','NumIterations',15);
    R=regionprops(W,BB,'PixelValues');
    Ind=zeros(numel(R),1);
    for J=1:numel(R)
        Ind(J)=mode(R(J).PixelValues);
    end
    B2=replace(W,[1:numel(R)],Ind);
    B2=medfilt2(B2,[opt.X(2),opt.X(2)]);
    clf; imagesc(cropper(B2)); CM=cm(); CM=[CM ;1-[.2,0,.35]]; colormap(CM); axis off equal; colorbar off; drawnow;
    printx(['Export/Frame_r' num2str(K) '.png']);
    bound=lab2edge(B2);
    t1=cropper(bound);
    t2=cropper(A2);
    CM2=bone(1024); CM2(1,:)=CM(3,:); clf; imagesc(t2.*(1-t1)); colormap(CM2); colorbar off; axis off; axis equal;
    printx(['Export/Frame_s' num2str(K) '.png']);
    BB=B2;
end
Lab2=BB;
end
function A=cropper(A);
S=size(A);
if S(1)<S(2);
    m=round((S(2)-S(1))/2); x1=1; x2=S(1); y1=m+1; y2=m+S(1);
end
if S(1)>=S(2);
    m=round((S(1)-S(2))/2); x1=m+1; x2=m+S(2); y1=1; y2=S(2);
end
A=A(x1:x2,y1:y2,:);
s=size(A);
m=round(s*.1);
A=A(m:end-m,m:end-m);
A=trim(A,30);
end
function [A]=replace(A,S1,S2)
% The replace function written by Jos van der Geest, email: jos@jasen.nl
error(nargchk(3,3,nargin)) ;
if ~isequal(iscell(A), iscell(S1), iscell(S2)),
    error('The arguments should be all cell arrays or not.') ;
end
if iscell(A),
    if ~all(cellfun('isclass',A(:),'char')),
        error('A should be a cell array of strings.') ;
    end
    if ~all(cellfun('isclass',S1(:),'char')),
        error('S1 should be a cell array of strings.') ;
    end
end
if ~isempty(S2),
    if numel(S2)==1,
        S2 = repmat(S2,size(S1)) ;
    elseif numel(S1) ~= numel(S2),
        error('The number of elements in S1 and S2 do not match ') ;
    end
end
[tf,loc] = ismember(A(:),S1(:)) ;
if nargout>1,
    tf = reshape(tf,size(A)) ;
end
if any(tf),
    if isempty(S2),
        A(tf) = [] ;
    else
        A(tf) = S2(loc(tf)) ;
    end
end
if ~iscell(S1),
    qsn = isnan(S1(:)) ;
    if any(qsn),
        qa = isnan(A(:)) ;
        if any(qa),
            if isempty(S2),
                A(qa) = [] ;
            else
                i = min(find(qsn)) ;
                A(qa) = S2(i) ;
            end
        end
    end
end
end
function [B]=lab2edge(L)
L1=imshift2(L,1,1);
L2=imshift2(L,2,1);
L3=imshift2(L1,2,1);
B=(L1~=L2)+(L1~=L3)+(L2~=L3);
B=B>0; B=double(B);
end
function make_video_gif
filename='Final.gif';
for I = 2:30
    A=imread(['Export/Frame_r' num2str(I) '.png']); A=A(:,200:end-200,:);
    B=imread(['Export/Frame_s' num2str(I) '.png']); B=B(:,200:end-200,:);
    A=cat(2,B,A); A2=uint8(ones(size(A,1)+60,size(A,2),size(A,3)).*255);
    A2(61:end,:,:)=A; A=A2; A=imresize(A,.3);
    [imind,cm] = rgb2ind(A,256);
    if I == 2;
        imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',0.05);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',0.05);
    end
end
end
function B=imshift2(A,x,N)
%mirrors the not-shifted pixels
B=A;
if ndims(A)==3
    if N>0
        switch x
            case 1
                B(1:end-N,:,:)=B(N+1:end,:,:);
                B(end-N:end,:,:)=flip(B(end-N:end,:,:),1);
            case 2
                B(:,1:end-N,:)=B(:,N+1:end,:);
                B(:,end-N:end,:)=flip(B(:,end-N:end,:),2);
            case 3
                B(:,:,1:end-N)=B(:,:,N+1:end);
                B(:,:,end-N:end)=flip(B(:,:,end-N:end),3);
        end
    end
    if N<0
        N=abs(N);
        switch x
            case 1
                B(N+1:end,:,:)=B(1:end-N,:,:);
                B(1:N,:,:)=flip(B(1:N,:,:),1);
            case 2
                B(:,N+1:end,:)=B(:,1:end-N,:);
                B(:,1:N,:)=flip(B(:,1:N,:),2);
            case 3
                B(:,:,N+1:end)=B(:,:,1:end-N);
                B(:,:,1:N)=flip(B(:,:,1:N),3);
        end
    end
end
if ndims(A)==2
    if N>0
        switch x
            case 1
                B(1:end-N,:)=B(N+1:end,:);
                B(end-N:end,:)=flip(B(end-N:end,:),1);
            case 2
                B(:,1:end-N)=B(:,N+1:end);
                B(:,end-N:end)=flip(B(:,end-N:end),2);
        end
    end
    if N<0
        N=abs(N);
        switch x
            case 1
                B(N+1:end,:)=B(1:end-N,:);
                B(1:N,:)=flip(B(1:N,:),1);
            case 2
                B(:,N+1:end)=B(:,1:end-N);
                B(:,1:N)=flip(B(:,1:N),2);
        end
    end
end
end
