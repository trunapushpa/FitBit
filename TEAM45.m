function [] = TEAM45(indir, outdir)

files = dir(strcat(indir,'/*.mat'));

for file = 1:size(files)
    inname = strcat(indir, '/', files(file).name);
    load(inname);
    ppg1 = sig(1,:);
    ppg2 = sig(2,:);
    a = [sig(3,:);sig(4,:);sig(5,:)];
    a2 = (a(1,:).*a(1,:)) + (a(2,:).*a(2,:)) + (a(3,:).*a(3,:));
    hr = zeros(size(a2,1)/2-250);
    k = 1;
    
    for i = 1:250:size(sig(1,:),2)-1000
        
        p1 = ppg1(i:i+1000-1);
        p2 = ppg2(i:i+1000-1);
        p1 = p1 - mean(p1);
        p2 = p2 - mean(p2);
        
        ff1 = fft(p1);
        ff2 = fft(p2);
        ff1(1,2:5)=0;
        ff2(1,2:5)=0;
        ff1(1,26:500)=0;
        ff2(1,26:500)=0;
        ff1(1,997:1000)=0;
        ff2(1,997:1000)=0;
        ff1(1,502:976)=0;
        ff2(1,502:976)=0;
        
        p1 = ifft(ff1);
        p2 = ifft(ff2);
        
        [~, loc1] = findpeaks(p1, 'MinPeakDistance', 40);
        [~, loc2] = findpeaks(p2, 'MinPeakDistance', 40);
        
        peaks = 0;
        
        if (size(loc1,2) >= size(loc2,1))
            for j=1:size(loc1,2)
                dif = min(abs(loc2 - loc1(1,j)));
                if (dif<41)
                    peaks = peaks + 1;
                end
            end
        else
            for j=1:size(loc2,2)
                dif = min(abs(loc1 - loc2(1,j)));
                if (dif<41)
                    peaks = peaks + 1;
                end
            end
        end
        
        no = peaks;
        heartrate = no*60/8;
        hr(k) = heartrate;
        k=1+k;
    end
    
    windowSize = 3;
    b = (1/windowSize)*ones(1,windowSize);
    a = 1;
    hr1 = filter(b,a,hr);
    
    pred = hr1(1,1:125);
    
    save(strcat(outdir,'/output_team_45_',files(file).name), 'pred');
    
end