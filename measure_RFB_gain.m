[Py,f] = plot_periodogram(y.data, 0);
[Pu,f] = plot_periodogram(u.data, 0);

Ay = sqrt(Py);
Au = sqrt(Pu);

% Calculate gains
Au2 = Au;
thresh = min(maxk(Au2,10));  % use a threshold to ignore divs by zero
Au2(Au2 < thresh) = nan;
G = Ay ./ Au2;


% Plot it
[~,imax] = max(Ay);
xmax = 3*f(imax);

figure
subplot(3,1,1)
plot(f,Ay)
ylabel('FFT (y)')
xlim([0 xmax])

subplot(3,1,2)
plot(f,Au)
ylabel('FFT (u)')
xlim([0 xmax])

subplot(3,1,3)
bar(f,G,4,'r')
xlim([0 xmax])
xlabel('Frequency [Hz]')
ylabel('Gain')































