ccc
t = 0.2 * [0:2000]';
x = sin(t);
y = 10*sin(t);
wave.time = t;
wave.signals.values = [x,y];
wave.signals.dimensions =2;