close all;
%clear all;
clc;
clearvars -except u y G_true P1D

NumOfFreqs = 5;

t = y.time;
U = u.data;
Y = y.data;

Ts = mean(diff(y.time));      % Sample time
Fs = 1/Ts;                    % Sampling frequency
L = length(y.data);           % Length of signal



NFFT = 2^nextpow2(L); % Next power of 2 from length of y
FTY = fft(Y,NFFT)/L;
FTU = fft(U,NFFT)/L;

NumUniquePts = ceil((NFFT+1)/2);
f = Fs/2*linspace(0,1,NumUniquePts);

MFTY    = 2*abs(FTY);
MFTY(1) = MFTY(1)/2;
MFTY    = MFTY(1:NumUniquePts);

MFTU = 2*abs(FTU);
MFTU(1) = MFTU(1)/2;
MFTU    = MFTU(1:NumUniquePts);


[MFTY_pks, MFTY_locs] = maxk(MFTY,NumOfFreqs);
fy = f(MFTY_locs);
[MFTU_pks, MFTU_locs] = maxk(MFTU,NumOfFreqs);
fu = f(MFTU_locs);

[MFTY_locs_sorted , IY] = sort(MFTY_locs);
[MFTU_locs_sorted, IU] = sort(MFTY_locs);
MFTY_pks_sorted = MFTY_pks(IY);
MFTU_pks_sorted = MFTU_pks(IU);

FTY_unique = FTY(1:NumUniquePts);
FTU_unique = FTU(1:NumUniquePts);

FTU_Nyq = FTU_unique(MFTU_locs_sorted);
FTY_Nyq = FTY_unique(MFTY_locs_sorted);

TFYU_Nyq = FTY_Nyq./FTU_Nyq;
f_Nyq    = f(MFTY_locs_sorted);

yint = trapz(Y);
uint = trapz(U);
SSgain = yint/uint;



if (sum(f_Nyq == 0) == 0)
    TF_YU = zeros(length(TFYU_Nyq)+1,1);
    f_YU = TF_YU;
    TF_YU(1) = SSgain;
    TF_YU(2:end) = TFYU_Nyq(1:end);
    f_YU(1) = 0;
    f_YU(2:end) = f_Nyq(1:end);
else
    TF_YU = TFYU_Nyq;
    f_YU  = f_Nyq;
end



TF = frd(TF_YU,f_YU);



figure(1)
% Plot time-domain signal
ax(1) = subplot(221);
plot(t, Y);
grid on
ylabel('Amplitude'); xlabel('Time (secs)');
title('Response (Y) time signal');
ylim([1.2*min(Y) 1.2*max(Y)])

fx(1) = subplot(222);
% Plot single-sided amplitude spectrum.
plot(f,MFTU) 
grid on
title('Single-Sided Amplitude Spectrum of u(t)')
xlabel('Frequency (Hz)')
ylabel('|U(f)|')

% Plot time-domain signal
ax(2) = subplot(223);
plot(t, U);
grid on
ylabel('Amplitude'); xlabel('Time (secs)');
title('Relay (u) time signal');
ylim([1.2*min(U) 1.2*max(U)])

fx(2) = subplot(224);
% Plot single-sided amplitude spectrum.
plot(f,MFTY) 
grid on
title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

linkaxes(ax,'x')
linkaxes(fx,'x')

figure(2)
scatter(real(TF_YU),imag(TF_YU))
grid on
hold on
nyquist(G_true)
nyquist(P1D)




% % Choose FFT size and calculate spectrum
% Nfft = length(U);%1024;
% [Puu,fu] = pwelch(U,gausswin(Nfft),Nfft/2,Nfft,fsamp);
% [Pyy,fy] = pwelch(Y,gausswin(Nfft),Nfft/2,Nfft,fsamp);
% % Get frequency estimate (spectral peak)
% [~,locu] = max(Puu);
% [~,locy] = max(Pyy);
% FREQ_ESTIMATEu = fu(locu)
% FREQ_ESTIMATEy = fy(locy)
% 
% for ii = 1:length(Puu)
%     G_est(ii) = Pyy(ii) /Puu(ii);
% end
% 
% 
% 
% 
% figure(1);
% % Plot time-domain signal
% ax(1) = subplot(3,2,1);
% plot(t, U);
% grid on
% ylabel('Amplitude'); xlabel('Time (secs)');
% %axis tight;
% title('Relay (u) time signal');
% ylim([1.2*min(U) 1.2*max(U)])
% 
% 
% % Plot frequency spectrum
% fx(1) =  subplot(3,2,2);
% plot(fu,Puu);
% ylabel('PSD'); xlabel('Frequency (Hz)');
% grid on;
% title(['Frequency estimate = ',num2str(FREQ_ESTIMATEu),' Hz']);
% 
% 
% ax(2) = subplot(3,2,3);
% plot(t, Y);
% grid on
% ylabel('Amplitude'); xlabel('Time (secs)');
% %axis tight;
% title('Response (y) time signal');
% ylim([1.2*min(Y) 1.2*max(Y)])
% 
% % Plot frequency spectrum
% fx(2) = subplot(3,2,4);
% plot(fy,Pyy);
% ylabel('PSD'); xlabel('Frequency (Hz)');
% grid on;
% title(['Frequency estimate = ',num2str(FREQ_ESTIMATEy),' Hz']);
% 
% % Plot frequency spectrum
% fx(3) = subplot(3,2,6);
% plot(fy,G_est);
% ylabel('PSD'); xlabel('Frequency (Hz)');
% grid on;
% title('G\_est');
% 
% 
% linkaxes(ax,'x')
% linkaxes(fx,'x')

