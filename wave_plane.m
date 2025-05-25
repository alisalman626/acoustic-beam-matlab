% K WAVE CODE M1 PROJECT 
clear all; clc;
% freq = 1; amp = 15 v
%% MEDIUM 
% PROPAGATION
speed_w = 1480; %m/s
% As we have a great wave length
dx = 2; % (step)
dy = 2;
Nx = 256; % 256 points
Ny = 512; % 512 

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

source_freq = 10;   % [Hz]
source_mag = 25;         % [Pa]
source.p = source_mag * sin(2 * pi * source_freq * kgrid.t_array);

% Filter Time Series
source.p = filterTimeSeries(kgrid, medium, source.p);

%% Sensor Mask
sensor.mask = ones(Nx, Ny);

%% Simulation 
% parameters to record
sensor.record = {'p', 'p_final'};

% Define the simulation input arguments
input_args = {
    'PMLSize', 10, ...
    'PMLAlpha', 2, ...
    'PMLInside', false, ...
    'DataCast', 'single', ...
    'MovieProfile', 'Motion JPEG AVI', ...
    'MovieArgs', {'FrameRate', 10, 'Quality', 100}, ....
    'RecordMovie', true, ... % record the entire simulation domain
    'MovieName', 'wave_plane.avi', ... % name of the movie fill
    'DisplayMask', 'off'
};

% simulation
sensor_data = kspaceFirstOrder2D(kgrid, medium, source, sensor, input_args{:});

focus_index = round(3.8*(length(kgrid.t_array))/4);
b = sensor_data.p(:, focus_index); % Focusing at t_end/2 (index 2133)
p_ = reshape(b, Nx, Ny); 

figure;
imagesc(p_);
colormap(getColorMap);
ylabel('tank width');
xlabel('tank length');
hold on; 
for k=1:length(source_positions)
    text(source_positions(k,2), source_positions(k,1), ['s', num2str(k)], 'FontSize', 12, 'Color', 'white');
end
c = colorbar;
c.Label.String = 'Pressure (in Pascal)';

