h=findall(0,'type','figure');
for k=1:length(h)
    figure(h(k))
    print('-djpeg100',sprintf('%i.jpeg',k));
end