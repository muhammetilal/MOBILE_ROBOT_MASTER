%% Simple Bayesian Filtering Example
% Rickey Wang
% A door opening robot with a very noisy sensor tries to open a door
% Asume that the door can be in one of two possible states, open
%   or closed, and that only the robot can change the state of the door.
% Assume that the robot does not know the state of the door initially. 
%   -> there is equally 50% chance for both open and close at the start

% This example uses the MATLAB command window. You generate
% your own input.
% See Thrun's textboook on Bayes Filters for detailed explanation
clear; clc; 

%% Parameters
% Motion Model
%          Xt = open   closed
%                +-    -+  Xt-1 =
% ut = none -->  | 1  0 |  Open
%                | 0  1 |  Closed
%                +-    -+
%                +-        -+  
% ut = open -->  | 1    0   | 
%                | 0.8  0.2 |  
%                +-        -+
motion_m = zeros(2,2,2);
motion_m(:,:,1) = [1 0; 0 1];
motion_m(:,:,2) = [1 0; 0.8 0.2];
% Measurement Model
%  measurements = {sens_open,sens_closed}
%  p(y|x)
%             x = open  closed
%                +-        -+ y =
%                | 0.6  0.2 | sens_open
%                | 0.4  0.8 | sens_closed
%                +-        -+
meas_m = [0.6 0.2; 0.4, 0.8];
% State Vector (boolean door open or closed)
X = [];
% Input vector
u = [];
% Measurement vector
y = [];

% Prompt user for inputs
get_inputs = 0;

%% Initial Set-up
% At beginning, assume the door is equally likely to be open or closed
% This forms our initial prior belief
bel_open = [];
bel_open = [bel_open; 0.5]; % Concatenate
done = 0;
t=0;
%% Running the model
while(~done)
    if (get_inputs)
        prompt = '0: none, 1: open   u = ';
        in = input(prompt);
    else
        in = 1;
    end
    
    while ~(~isempty(in) ...
            && isnumeric(in) ...
            && isreal(in) ...
            && isfinite(in) ...
            && (in == fix(in)) ...
            && (in >= 0) ...
            && (in <=1))
        in = input(prompt);
    end
    
    u = [u; in];
    if (get_inputs)
        prompt = '0: sens_open, 1: sens_closed   y = ';
        in = input(prompt);
    else
        in = 1;
    end
    while ~(~isempty(in) ...
        && isnumeric(in) ...
        && isreal(in) ...
        && isfinite(in) ...
        && (in == fix(in)) ...
        && (in >= 0) ...
        && (in <=1))
    in = input(prompt);
    end
    y = [y; in];
    
    bel_open_pri = [bel_open(end), 1-bel_open(end)];
    % The biggest challenge is figuring out what to put here:
    bf_open = bayes_filter(motion_m(:,:,u(end)+1)', meas_m(y(end)+1,:)', bel_open_pri');
    bel_open = [bel_open; 1/(sum(bf_open(:,2)))*bf_open(1,2)];
    
    %prompt = sprintf('bel(open)=%f',bel_open(end));
    %disp(prompt)
    
    fprintf('%3s %3s %10s\r\n','u','y','bel_open');
    fprintf('%3i %3i %10.5f\r\n',[u y bel_open(2:end)]'); % Yes, this printing is a bit unintuitive. 
    t = t+1;
    if (t==2)
        done = 1;
    end
end



