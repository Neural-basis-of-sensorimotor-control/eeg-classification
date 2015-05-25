clear
close all
%directory = '../sc_mat/';
[~,txt] = xlsread('../neuro-text/eeg/Enheter efter BENR med möjlig spike-EEG analys.xlsx');

txt = txt(:,1);
for k=1:length(txt)
    str = txt{k};
    if str(1) == '('
        str = str(2:end-1);
    end
    txt(k) = {str(1:end-4)};
end
txt = unique(txt);
for k=1:length(txt)
    clf
    str = txt{k};
    h = Eeg(sprintf('%s_sc.mat',str));
    h.plot_eeg(-.1,.1,1e-3,0)
end

return
d = what(directory);
filenames = d.mat;
found_eeg = false
k = 1;

while ~found_eeg && k<=length(filenames)
    disp(filenames{k})
    expr = load(sprintf('%s%s', directory, filenames{k}));
    expr = expr.obj;
    j = 1;
    while ~found_eeg && j<=expr.n
        file = expr.get(j);
        disp(file.tag)
        m = 1;
        while ~found_eeg && m<=file.signals.n
            disp(file.signals.get(m).tag)
            found_eeg = strcmp(file.signals.get(m).tag,'EEG');
            m = m+1;
        end
        j = j+1;
    end
    k=k+1;
end

f = EegFigure(expr);