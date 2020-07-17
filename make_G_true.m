K = 1;
T = 0.1;
D = 0.01;
s = tf('s');
G_true = (K/(1+T*s))*exp(-D*s);

