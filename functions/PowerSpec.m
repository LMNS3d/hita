function [spectrum,k,bin_counter,time] = PowerSpec(u,v,w,...
                                                   L,dim)
	tic;
	uu_fft=fftn(u);
	vv_fft=fftn(v);
	ww_fft=fftn(w);
	
	muu = abs(uu_fft)/length(u)^3;
	mvv = abs(vv_fft)/length(v)^3;
	mww = abs(ww_fft)/length(w)^3;

	muu = muu.^2;
	mvv = mvv.^2;
	mww = mww.^2;
    
% % 	rx=[0:1:dim-1] - (dim-1)/2;
% %     ry=[0:1:dim-1] - (dim-1)/2;
% %     rz=[0:1:dim-1] - (dim-1)/2;
% %     
% % 	test_x=circshift(rx',[(dim+1)/2 1]);
% % 	test_y=circshift(ry',[(dim+1)/2 1]);
% % 	test_z=circshift(rz',[(dim+1)/2 1]);
	rx=[0:1:dim-1] - (dim)/2+1;
    ry=[0:1:dim-1] - (dim)/2+1;
    rz=[0:1:dim-1] - (dim)/2+1;
    
	test_x=circshift(rx',[(dim)/2+1 1]);
	test_y=circshift(ry',[(dim)/2+1 1]);
	test_z=circshift(rz',[(dim)/2+1 1]);
	
	[X,Y,Z]= meshgrid(test_x,test_y,test_z);
	r=(sqrt(X.^2+Y.^2+Z.^2));

    dx=2*pi/L;
    k=[1:(dim)/2].*dx;
    
    spectrum=zeros(size(k,2),1);
    bin_counter=zeros(size(k,2),1);
	for N=2:(dim-1)/2-1
        picker = (r(:,:,:)*dx <= (k(N+1) + k(N))/2) & ...
                 (r(:,:,:)*dx > (k(N) + k(N-1))/2);
		spectrum(N) = sum(muu(picker))+...
                      sum(mvv(picker))+...
                      sum(mww(picker));
        bin_counter(N) = size(find(picker==1),1);
    end
    % compute first value of spectrum
    picker = (r(:,:,:)*dx <= (k(2) + k(1))/2);
    spectrum(1) = sum(muu(picker))+...
                  sum(mvv(picker))+...
                  sum(mww(picker));
    bin_counter(1) = size(find(picker==1),1);
    % compute last value of spectrum
    picker = (r(:,:,:)*dx > (k(end) + k(end-1))/2 & ...
              r(:,:,:)*dx <= k(end));
    spectrum(end) = sum(muu(picker))+...
                    sum(mvv(picker))+...
                    sum(mww(picker));
    bin_counter(end) = size(find(picker==1),1);
    %compute final spectrum
    spectrum = spectrum*2*pi.*k'.^2./(bin_counter.*dx.^3);
	time=toc;
end
