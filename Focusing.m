% K WAVE CODE M1 PROJECT 
clear all; clc;

%% MEDIUM 
% PROPAGATION
freq = 10; % in Hz
speed_w = 1480; %m/s
% As we have a great wave length
dx = 2; % 30mm (step)
dy = 2;
Nx = 256; % 256 points
Ny = 512; % 

% K space grid 
kgrid = kWaveGrid(Nx, dx, Ny, dy);

% Medium properties
medium.sound_speed = speed_w;
medium.alpha_coeff = 2.2e-3; % Attenuation
medium.alpha_power = 1.02;
medium.density = 1000; % Kg/m^3

%% SOURCE 
% Simulation time
t_end = 3 * kgrid.x_size / max(medium.sound_speed(:));
kgrid.makeTime(medium.sound_speed, [], t_end);

source_positions = [44, 50; 86, 50; 128, 50; 170, 50; 212, 50];
num_sources = size(source_positions, 1);

% source mask
source.p_mask = zeros(Nx, Ny);
for i = 1:num_sources
    source.p_mask(source_positions(i,1), source_positions(i,2)) = 1;
end

% Source parameters
source_freq = 10;   % [Hz]
source_mag = 25;     % [Pa]
% Foacusing  
focus_point_pixels = [128, 256]; % Focal point
t_focus = t_end / 2;  
% Computing of delays
travel_times = zeros(num_sources, 1);  
delays = [0, 105*pi/(180*2), 105*pi/(180), 105*pi/(180*2), 0];

%time-delayed signals for each source
source.p = zeros(num_sources, length(kgrid.t_array));
for i = 1:num_sources
    current_delay = delays(i);
    signal = source_mag * sin((2 * pi * source_freq * kgrid.t_array) - current_delay);
    source.p(i, :) = signal;
end

% Filter Time Series
%source.p = filterTimeSeries(kgrid, medium, source.p);

%% Sensor Mask
sensor.mask = ones(Nx, Ny);

%% Simulation 
% parameters to record
sensor.record = {'p', 'p_final'}; % , 'p_final'
input_args = {
    'PMLSize', 10, ...
    'PMLAlpha', 2, ...
    'PMLInside', false, ...
    'DataCast', 'single', ...
    'MovieProfile', 'Motion JPEG AVI', ...
    'MovieArgs', {'FrameRate', 10, 'Quality', 80}, ....
    'RecordMovie', true, ... % record the entire simulation domain
    'MovieName', 'Focusing.avi', ... % name of the movie
    'DisplayMask', 'off'
};

% simulation
sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor, input_args{:});
% Plotting
time_differences = abs(kgrid.t_array - t_focus);
[min_diff, focus_index] = min(time_differences);

b = sensor_data.p(:, focus_index); % Focusing at t_end/2 (index 2133)
p_ = reshape(b, Nx, Ny); 

figure;
imagesc(p_);
colormap(getColorMap);
ylabel('tank width');
xlabel('tank length');
colorbar;
