function [mainWindowPtr, mainWindowRect, centerPt] = screenSetup(bgcolor)
% [mainWindowPtr, mainWindowRect, centerPt] = screenSetup(bgcolor)
%
% Purpose:  set basic screen vars & open main screen,
% Return:   main Window pointer, main window rect, center point
%
% If this command is executed on Microsoft Windows:
%   Screen 0 is always the full Windows desktop.
%   Screens 1 to n are corresponding to windows display monitors 1 to n.
% If you want to open an onscreen window only on one specific display,
%   or you want to query or set the properties of  display
%   (e.g., framerate, size, colour depth or gamma tables), use the screen numbers 1 to n.

% global expt
expt.screen.mainScreenNum   = max(Screen('Screens')); % finds display to present
expt.screen.pixelSize       = 32;   % 32 bits per pixel
expt.screen.numBuffers      = 2;    % double buffering: use >2 for development/debugging of PTB itself but will mess up any real experiment
expt.screen.screenRect      = [];   % use default screen rect
expt.screen.defaultBgcolor  = bgcolor; % black

% Execute %
[mainWindowPtr, mainWindowRect]=Screen('OpenWindow', expt.screen.mainScreenNum, ...
    expt.screen.defaultBgcolor, ...
    expt.screen.screenRect,...
    expt.screen.pixelSize,...
    expt.screen.numBuffers);
Screen('BlendFunction', mainWindowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
centerPt.x = (mainWindowRect(3) / 2);
centerPt.y = (mainWindowRect(4) / 2);


% set the state of the random number generator to some random value (based on the clock)
tau = clock;
rand('state',sum(100*tau));
expt.RandState=rand('state');
end