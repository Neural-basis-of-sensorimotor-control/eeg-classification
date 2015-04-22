clear
directory = '../sc_mat/';
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