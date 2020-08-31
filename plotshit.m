% ======================
% TIMETRACES AND SPECTRA
% ======================
figure

% Plot time-domain signal y
ax(1) = subplot(221);
hold on
plot(t, y.data, 'b');
plot(t, yclean, 'r');
grid on
ylabel('Amplitude'); 
xlabel('Time (secs)');
title('Response (Y) time signal');
ylim([1.2*min(y.data) 1.2*max(y.data)])
xlim([0 Tsim])

% Plot FFT y
fx(1) = subplot(222);
plot(f, Ay) 
grid on
hold on
scatter(f(ipks_y), Ay(ipks_y),'r', 'filled')
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')
xlim([0 f(ipks(end)) * 2])
legend('Amplitude FFT\_Y ','selected points')
ylim([-.05 1.2]*max(Ay))


% Plot time-domain signal u
ax(2) = subplot(223);
plot(t, udata, 'b');
grid on
ylabel('Amplitude'); 
xlabel('Time (secs)');
title('Relay (u) time signal');
ylim([1.2*min(udata) 1.2*max(udata)])
xlim([0 Tsim])


% Plot single-sided amplitude spectrum.
fx(2) = subplot(224);
plot(f, Au) 
grid on
hold on
scatter(f(ipks_u), Au(ipks_u), 'r', 'filled')
title('Single-Sided Amplitude Spectrum of u(t)')
xlabel('Frequency (Hz)')
ylabel('|U(f)|')
xlim([0 f(ipks(end))*2])
legend('Amplitude FFT\_U ','selected points')
ylim([-.05 1.2]*max(Au))

linkaxes(ax,'x')
linkaxes(fx,'x')
set(gcf, 'position', [564 78 560 420])

% ============
% NYQUIST PLOT
% ============
figure
hold on
nyquist(G_true, 'b')
nyquist(G_fit, 'r')
scatter( real(gains_meas), imag(gains_meas), 'r', 'filled')
x = 1.2*abs(gains_meas(3)) * [0 cosd(-150)];
y = 1.2*abs(gains_meas(3)) * [0 sind(-150)];
% plot(x,y,'g','linewidth',1.5)
legend('True Model', 'Fit Model', 'Measured Gains')
set(gcf, 'position', [1 76 560 420])
xlim([-1.2 1.2]*abs(Kp))






