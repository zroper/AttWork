%-----------------------------------------------------------------
% Monetary cost of attentional work
%
% created on 11/10/2016
% Zachary J.J. Roper, Ph.D.
% Vanderbilt University
% Nashville, TN
%-----------------------------------------------------------------

AssertOpenGL; %Makes sure script is running on Psychtoolbox3

clc; %clears monitor
clear variables; %clears memory

%cd /Users/grad_user/Dropbox/Experiments/AttWork

%------------------------------------------------------
%   Set up subject number, tell MATLAB what to name data file
%------------------------------------------------------
% input the subject id

disp('e: experiment, p: practice');
expType=input('Enter experiment type: ', 's');

%-----------------------------------------------------------------
%  Counterbalance versions
%-----------------------------------------------------------------


CBPossibilities = [1,2,3,4,5,6];
CBSelect = Shuffle(CBPossibilities);

if expType == 'e'
    CBSelect(1) = input('Enter CB value: ');
end

if CBSelect(1) > 6
    disp('CB value must be between 1 and 6');
    disp('Experiment aborted')
    return
end

if expType == 'e'
    ID = input('Enter Subject Number: ', 's');
    
    SN = str2double(ID);
    
    %set default values for input arguments
    if ~exist('ID','var')
        ID= 66;
    end
    
    %warn if duplicate subject ID
    FileName = strcat(ID, '_AttWork_ResourceTaxed.csv');
    if exist(FileName, 'file')
        
        resp=input(['the file ' FileName ' already exists. Do you want to overwrite it? [Type ok for overwrite]'], 's');
        if ~strcmp(resp, 'ok') %abort experiment if overwite not confirmed
            disp('Experiment aborted')
            return
        end
    end
    FID = fopen(FileName, 'w');
    fprintf(FID, 'Order, BlockNumber, Block, Condition, CBversion, CueLocation, DifficultyLevel, TargetID, RelativeProportion, TargetQuad, Trial, Subject, Response_Cue, Response_Choice, Response_Search, BasicIncome, WorkIncome, EarnedIncome, Accuracy, RT_Cue, RT_Search\n'); %\n=enter - moves to next row
    fclose(FID);
end                              

%-------------------------------------------------------
% Setting up random seed, screen, colors, gamepad, and event code
%-------------------------------------------------------

HideCursor; %hides cursor so subjects can't see it
%rng(sum(100*clock),'twister');
bgColour=[0 0 0];
[window, mainWindowRect, centerPt]= screenSetup(bgColour);
expt.winPtr = window;
priorityLevel= MaxPriority(window);
Priority(priorityLevel);

%screen = 0; %opens the main presentation window
%[window,rect] = Screen('OpenWindow', screen, [0 0 0], [0 0 1024 768]);
Arraywindow = Screen('OpenOffscreenWindow', expt.winPtr, [0 0 0], [0 0 700 700]);


CX=512;
CY=384;

% fx = 20/2;
% fy = 20/2;
 
dx = 700/2;
dy = 700/2;

objectSize = 20;
gapSize = 6;

black = [0 0 0];
white = [255 255 255];
red = [255 0 0];
blue = [0 0 255];
green = [0 255 0];
yellow = [255 255 0];
gray = [100 100 100];

timing=Screen('GetFlipInterval',window);% get the flip rate of current monitor.
timingcorrection=timing/2; %this ensures proper timing of the flips by making sure the command has enough time to execute before the next screen refresh


%-----------------------------------------------------------------
%   Present Instructions
%-----------------------------------------------------------------
InstructionText = ['Welcome to the Experiment!\n\n\n\n' 'Press any key to continue.'];
InstructionText2 = ['On each trial you will be given a choice between two options as indicated by circles\n\n'...
    'One option will award you points immediately and the other option\n will require you to do some work in exchange for more points\n\n'...
    'The more points you earn, the more money you will recieve at the end of the experiment (up to $10 bonus)\n\n'...
    'If you choose the left option, then press the "Z" key\n\n'...
    'If you choose the right option, then press the "/?" key\n\n'...
    'If you choose to work, you will then have to find the letter T\n\n'...
    'If the T is tilted to the left, then press the "Z" key\n\n'...
    'If the T is tilted to the right, then press the "/?" key\n\n'...
    'Please respond as fast and accurately as possible\n\n\n\n'...
    'Press any key to begin'];

Screen(window,'TextSize', 18);

DrawFormattedText (window, InstructionText, 'center', 'center', white);
Screen('Flip', window);
KbWait([],2);

Screen('FillRect', window, [0 0 0]);
Screen('Flip', window);

DrawFormattedText (window, InstructionText2, 'center', 'center', white);
Screen('Flip', window);
KbWait([],2);

Screen('FillRect', window, [0 0 0]);
Screen('Flip', window);

%-----------------------------------------------------------------
% Load Images
%-----------------------------------------------------------------

%Current Distractors
DistractorV = imread('Stimuli/Stim_V_White.jpg');
DistractorJ = imread('Stimuli/Stim_J_White.jpg');
DistractorK = imread('Stimuli/Stim_K_White.jpg');
DistractorS = imread('Stimuli/Stim_S_White.jpg');
DistractorR = imread('Stimuli/Stim_R_White.jpg');
DistractorO = imread('Stimuli/Stim_O_White.jpg');

%Current Targets
TargetZ = imread('Stimuli/Stim_Z_White.jpg');
TargetX = imread('Stimuli/Stim_X_White.jpg');
NeutralP = imread('Stimuli/Stim_P_White.jpg');

TargetZ_Red = imread('Stimuli/Stim_Z_Red.jpg');
TargetX_Red = imread('Stimuli/Stim_X_Red.jpg');
NeutralP_Red = imread('Stimuli/Stim_P_Red.jpg');

TargetZ_Green = imread('Stimuli/Stim_Z_Green.jpg');
TargetX_Green = imread('Stimuli/Stim_X_Green.jpg');
NeutralP_Green = imread('Stimuli/Stim_P_Green.jpg');

TargetZ_Blue = imread('Stimuli/Stim_Z_Blue.jpg');
TargetX_Blue = imread('Stimuli/Stim_X_Blue.jpg');
NeutralP_Blue = imread('Stimuli/Stim_P_Blue.jpg');

%Search Stimuli
Lefty = imread('Stimuli/Left_T_black.jpg');
Righty = imread('Stimuli/Right_T_black.jpg');
Dist1 = imread('Stimuli/Dist_L1_resized.jpg');
Dist2 = imread('Stimuli/Dist_L2_resized.jpg');
Dist3 = imread('Stimuli/Dist_L3_resized.jpg');
Dist4 = imread('Stimuli/Dist_L4_resized.jpg');

%Cue Images

[BlueCue , ~, alpha] = imread('Stimuli/BlueCue.png');
BlueCue(:,:,4) = alpha(:,:);
[CyanCue , ~, alpha] = imread('Stimuli/CyanCue.png');
CyanCue(:,:,4) = alpha(:,:);
[YellowCue , ~, alpha] = imread('Stimuli/YellowCue.png');
YellowCue(:,:,4) = alpha(:,:);
[RedCue , ~, alpha] = imread('Stimuli/RedCue.png');
RedCue(:,:,4) = alpha(:,:);
[OrangeCue , ~, alpha] = imread('Stimuli/OrangeCue.png');
OrangeCue(:,:,4) = alpha(:,:);
[MagentaCue , ~, alpha] = imread('Stimuli/MagentaCue.png');
MagentaCue(:,:,4) = alpha(:,:);
[GreenCue , ~, alpha] = imread('Stimuli/GreenCue.png');
GreenCue(:,:,4) = alpha(:,:);
[WhiteCue , ~, alpha] = imread('Stimuli/WhiteCue.png');
WhiteCue(:,:,4) = alpha(:,:);
[Box , ~, alpha] = imread('Stimuli/Box.png');
Box(:,:,4) = alpha(:,:);

Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


%--------------------------------------------------------------------
%  Block Loop
%--------------------------------------------------------------------


jj=0;
Base = 0;
NumberofBlocks = 3;

for jj = 0 : NumberofBlocks-1
    
    
    
%-----------------------------------------------------------------
%  Condition Distribution
%-----------------------------------------------------------------
    TarID = 2; %X or Z
    LevDiff = 4; %Four difficulty levels (easy, med, hard, very hard)
    RelProp = 10; %Ten levels of relative value proportions
    TarQuad = 4; %Four quadrants for the target
    CueLoc = 2; %Choice cue left/right
    
    
    Repetition = 3;
    
    
    TotalTrial = TarID*LevDiff*RelProp*TarQuad*CueLoc; %640
    
    Condition = zeros(1,TotalTrial*2);
    Condition(1:TotalTrial) = 1;
    Condition(TotalTrial+1:TotalTrial*2) = 2;
    
    tt=0;
    
    for tt = 0 : 1 %Train and Test
        
%-----------------------------------------------------------------
% Condition Initialization
%-----------------------------------------------------------------
        TargetID = zeros(1, TotalTrial);
        LevelDiff = zeros(1, TotalTrial);
        RelativeProp = zeros(1, TotalTrial);
        TargetQuad = zeros(1, TotalTrial);
        CueLocation = zeros(1, TotalTrial);
        Subject = zeros(1, TotalTrial);
        Block = zeros(1, TotalTrial);
        RT_Cue = zeros(1, TotalTrial);
        RT_Search = zeros(1, TotalTrial);
        Response_Cue = zeros(1, TotalTrial);
        Response_Choice = zeros(1, TotalTrial);
        Response_Search = zeros(1, TotalTrial);
        Accuracy = zeros(1, TotalTrial);
        Order = zeros(1, TotalTrial);
        ThisTrial = zeros(1, TotalTrial);
        Reward = zeros(1, TotalTrial);
        BlockNumber = zeros(1,TotalTrial);
        EarnedIncome = zeros(1, TotalTrial);
        BasicIncome = ceil(normrnd(200,20,1,TotalTrial))';
        MultiFactor = (1:10);
        IncomeMatrix = BasicIncome * MultiFactor;
        MaxValue = max(IncomeMatrix(:,10));
        SecondQuad = [1,2,3];
        ThirdQuad = [1,2];
        Cue_Key = zeros(1, TotalTrial);
        Search_Key = zeros(1, TotalTrial);
        SearchCorrect = 0;
        SearchWrong = 0;
        
        
        for i=0 : TotalTrial-1
            
            
            TargetID(i+1) = mod(i/320, TarID);
            TargetID(i+1) = floor(TargetID(i+1))+1;
            
            TargetQuad(i+1) = mod(i/80, TarQuad);
            TargetQuad(i+1) = floor(TargetQuad(i+1))+1;
            
            RelativeProp(i+1) = mod(i/8, RelProp);
            RelativeProp(i+1) = floor(RelativeProp(i+1))+1;
            
            CueLocation(i+1) = mod(i/4, CueLoc);
            CueLocation(i+1) = floor(CueLocation(i+1))+1;
            
            LevelDiff(i+1) = mod(i/1, LevDiff);
            LevelDiff(i+1) = floor(LevelDiff(i+1))+1;
            
            Order(i+1) = i+1;
            
        end
        
        
%--------------------------------------------------------------------
% For 1:TotalTrial - to allow you to loop through the code and
% 		present multiple trials during the experiment
%--------------------------------------------------------------------
        Order = randperm(TotalTrial);
        
        if expType == 'p'
            TotalTrial = 36;
        end
        
        for Trial = 1 : TotalTrial
            
%--------------------------------------------------------------------
%  Locations
%--------------------------------------------------------------------
            
            
            ULQuad = [20 20 340 340];
            URQuad = [360 20 680 360];
            LLQuad = [20 360 340 680];
            LRQuad = [360 360 680 680];          
            
            CueLocationLeft = [349 349 419 419]; %Left
            CueLocationRight = [605 349 675 419]; %Right
            
            
%--------------------------------------------------------------------
%  Choose Difficulty Level and Cue Color
%--------------------------------------------------------------------
            if expType == 'e'
                if Condition(Trial+TotalTrial*tt) == 1
                    if LevelDiff(Order(Trial)) == 1
                        CueStim = red;
                    elseif LevelDiff(Order(Trial)) == 2
                        CueStim = blue;
                    elseif LevelDiff(Order(Trial)) == 3
                        CueStim = green;
                    elseif LevelDiff(Order(Trial)) == 4
                        CueStim = yellow;
                    end
                end
            elseif expType == 'p'
                CueStim = white;
            end
            
%--------------------------------------------------------------------
%  Choose Cue Location
%--------------------------------------------------------------------
            if CueLocation(Order(Trial)) == 1
                CueLoc1 = CueLocationLeft;
                CueLoc2 = CueLocationRight;
            elseif CueLocation(Order(Trial)) == 2
                CueLoc1 = CueLocationRight;
                CueLoc2 = CueLocationLeft;
            end
%--------------------------------------------------------------------
%  Choose Reward Values
%--------------------------------------------------------------------
            BasicIncomeLevel = 3;
            BasicIncomeValue = num2str(IncomeMatrix(Trial,BasicIncomeLevel));
            WorkIncomeValue = num2str(IncomeMatrix(Trial,RelativeProp(Order(Trial))));
            
%--------------------------------------------------------------------
%  Choose Arc Angles
%--------------------------------------------------------------------
            clear BasicEndAngle WorkEndAngle
     
            BasicAngle = 360/MaxValue*IncomeMatrix(Trial,BasicIncomeLevel);
            BasicAngleAdd = randi([0,360],1);
            
            if BasicAngle + BasicAngleAdd < 360
                BasicStartAngle = BasicAngleAdd;
                BasicEndAngle = BasicAngle + BasicAngleAdd;
            elseif BasicAngle + BasicAngleAdd >= 360
                BasicStartAngle = 0;
                BasicEndAngle = BasicAngle;
            end
                      
            WorkAngle = 360/MaxValue*IncomeMatrix(Trial,RelativeProp(Order(Trial)));
            WorkAngleAdd = randi([0,360],1);

            if WorkAngle + WorkAngleAdd < 360
                WorkStartAngle = WorkAngleAdd;
                WorkEndAngle = WorkAngle + WorkAngleAdd;
            elseif WorkAngle + WorkAngleAdd >= 360
                WorkStartAngle = 0;
                WorkEndAngle = WorkAngle;
            end
            
%--------------------------------------------------------------
% Select Quadrants
%--------------------------------------------------------------
            
            SecondQuadSelect = Shuffle(SecondQuad);
            ThirdQuadSelect = Shuffle(ThirdQuad);
            
            %------------Stimulus Locations Based on CreatePoints.m
            if TargetQuad(Order(Trial)) == 1 % Upper Left Quad
                Quad1 = ULQuad;
                if SecondQuadSelect(1) == 1
                    Quad2 = URQuad;
                    if ThirdQuadSelect(1) == 1
                        Quad3 = LLQuad;
                        Quad4 = LRQuad;
                    elseif ThirdQuadSelect(1) == 2
                        Quad3 = LRQuad;
                        Quad4 = LLQuad;
                    end
                elseif SecondQuadSelect(1) == 2
                    Quad2 = LLQuad;
                    if ThirdQuadSelect(1) == 1
                        Quad3 = URQuad;
                        Quad4 = LRQuad;
                    elseif ThirdQuadSelect(1) == 2
                        Quad3 = LRQuad;
                        Quad4 = URQuad;
                    end
                elseif SecondQuadSelect(1) == 3
                    Quad2 = LRQuad;
                    if ThirdQuadSelect(1) == 1
                        Quad3 = LLQuad;
                        Quad4 = URQuad;
                    elseif ThirdQuadSelect(1) == 2
                        Quad3 = URQuad;
                        Quad4 = LLQuad;
                    end
                end
            elseif TargetQuad(Order(Trial)) == 2 % Upper Right Quad
                Quad1 = URQuad;
                if SecondQuadSelect(1) == 1
                    Quad2 = ULQuad;
                    if ThirdQuadSelect(1) == 1
                        Quad3 = LLQuad;
                        Quad4 = LRQuad;
                    elseif ThirdQuadSelect(1) == 2
                        Quad3 = LRQuad;
                        Quad4 = LLQuad;
                    end
                elseif SecondQuadSelect(1) == 2
                    Quad2 = LLQuad;
                    if ThirdQuadSelect(1) == 1
                        Quad3 = ULQuad;
                        Quad4 = LRQuad;
                    elseif ThirdQuadSelect(1) == 2
                        Quad3 = LRQuad;
                        Quad4 = ULQuad;
                    end
                elseif SecondQuadSelect(1) == 3
                    Quad2 = LRQuad;
                    if ThirdQuadSelect(1) == 1
                        Quad3 = LLQuad;
                        Quad4 = ULQuad;
                    elseif ThirdQuadSelect(1) == 2
                        Quad3 = ULQuad;
                        Quad4 = LLQuad;
                    end
                end
            elseif TargetQuad(Order(Trial)) == 3 % Lower Left Quad
                Quad1 = LLQuad;
                if SecondQuadSelect(1) == 1
                    Quad2 = URQuad;
                    if ThirdQuadSelect(1) == 1
                        Quad3 = ULQuad;
                        Quad4 = LRQuad;
                    elseif ThirdQuadSelect(1) == 2
                        Quad3 = LRQuad;
                        Quad4 = ULQuad;
                    end
                elseif SecondQuadSelect(1) == 2
                    Quad2 = LRQuad;
                    if ThirdQuadSelect(1) == 1
                        Quad3 = URQuad;
                        Quad4 = ULQuad;
                    elseif ThirdQuadSelect(1) == 2
                        Quad3 = ULQuad;
                        Quad4 = URQuad;
                    end
                elseif SecondQuadSelect(1) == 3
                    Quad2 = ULQuad;
                    if ThirdQuadSelect(1) == 1
                        Quad3 = LRQuad;
                        Quad4 = URQuad;
                    elseif ThirdQuadSelect(1) == 2
                        Quad3 = URQuad;
                        Quad4 = LRQuad;
                    end
                end
            elseif TargetQuad(Order(Trial)) == 4 % Lower Right Quad
                Quad1 = LRQuad;
                if SecondQuadSelect(1) == 1
                    Quad2 = URQuad;
                    if ThirdQuadSelect(1) == 1
                        Quad3 = LLQuad;
                        Quad4 = ULQuad;
                    elseif ThirdQuadSelect(1) == 2
                        Quad3 = ULQuad;
                        Quad4 = LLQuad;
                    end
                elseif SecondQuadSelect(1) == 2
                    Quad2 = LLQuad;
                    if ThirdQuadSelect(1) == 1
                        Quad3 = URQuad;
                        Quad4 = ULQuad;
                    elseif ThirdQuadSelect(1) == 2
                        Quad3 = ULQuad;
                        Quad4 = URQuad;
                    end
                elseif SecondQuadSelect(1) == 3
                    Quad2 = ULQuad;
                    if ThirdQuadSelect(1) == 1
                        Quad3 = LLQuad;
                        Quad4 = URQuad;
                    elseif ThirdQuadSelect(1) == 2
                        Quad3 = URQuad;
                        Quad4 = LLQuad;
                    end
                end
            end
            
            point4 = [Quad1; Quad1; Quad1; Quad1]; %chooses 4 points within "list"
            point8 = [Quad1; Quad1; Quad1; Quad1; %chooses 8 points within "list"
                Quad2; Quad2; Quad2; Quad2];
            point12 = [Quad1; Quad1; Quad1; Quad1; %chooses 12 points within "list"
                Quad2; Quad2; Quad2; Quad2;
                Quad3; Quad3; Quad3; Quad3];
            point16 = [Quad1; Quad1; Quad1; Quad1; %chooses 16 points within "list"
                Quad2; Quad2; Quad2; Quad2;
                Quad3; Quad3; Quad3; Quad3;
                Quad4; Quad4; Quad4; Quad4];
            point32 = repmat(point16,2,1);
            point48 = repmat(point16,3,1);
            point64 = repmat(point16,4,1);
            point128 = repmat(point16,8,1);
%--------------------------------------------------------------
% Select Stimulus Locations
%--------------------------------------------------------------

            if LevelDiff(Order(Trial)) == 1 % set size 4
                points = point4;
                items = 4;
            elseif LevelDiff(Order(Trial)) == 2 % set size 8
                points = point16;
                items = 16;
            elseif LevelDiff(Order(Trial)) == 3  % set size 12
                points = point32;
                items = 32;
            elseif LevelDiff(Order(Trial)) == 4  % set size 16
                points = point128;
                items = 128;                
            end
            
            locations = createPoints(points, [dx dy], 25, 20, 10000);
            %-----------------------------------------------------------------------------Draw fixation for DisplayWindows
            %screen(DisplayWindow(1), 'FillRect', [74 74 74], [dx-10 dy-1 dx+10 dy+1]);
            %screen(DisplayWindow(1), 'FillRect', [74 74 74], [dx-1 dy-10 dx+1 dy+10]);
            %----------------------------------------------------------------------------- Draw target and distractors
            for i = 1 : items
                %-------------------------------------------------------------------------For target
                if TargetID(Order(Trial)) == 1 % Lefty Target
                    if i == 1 % first item is always a target
                        Screen('PutImage', Arraywindow, Lefty,[locations(i,1) locations(i,2) locations(i,1)+objectSize locations(i,2)+objectSize]);
                    else
                        if i <= items - (3*items/4) %Assign locations for the first quarter of distractors
                            Screen('PutImage', Arraywindow, Dist1,[locations(i,1) locations(i,2) locations(i,1)+objectSize locations(i,2)+objectSize]);
                        elseif i <= items - (items/2) %Assign locations for the second quarter of distractors
                            Screen('PutImage', Arraywindow, Dist2,[locations(i,1) locations(i,2) locations(i,1)+objectSize locations(i,2)+objectSize]);
                        elseif i <= items - (items/4) %Assign locations for the third quarter of distractors
                            Screen('PutImage', Arraywindow, Dist3,[locations(i,1) locations(i,2) locations(i,1)+objectSize locations(i,2)+objectSize]);
                        else %Assign locations for the fourth quarter of distractors
                            Screen('PutImage', Arraywindow, Dist4,[locations(i,1) locations(i,2) locations(i,1)+objectSize locations(i,2)+objectSize]);
                        end
                    end
                elseif TargetID(Order(Trial)) == 2 % Righty Target
                    if i == 1 % first item is always a target
                        Screen('PutImage', Arraywindow, Righty,[locations(i,1) locations(i,2) locations(i,1)+objectSize locations(i,2)+objectSize]);
                    else
                        if i <= items - (3*items/4) %Assign locations for the first quarter of distractors
                            Screen('PutImage', Arraywindow, Dist1,[locations(i,1) locations(i,2) locations(i,1)+objectSize locations(i,2)+objectSize]);
                        elseif i <= items - (items/2) %Assign locations for the second quarter of distractors
                            Screen('PutImage', Arraywindow, Dist2,[locations(i,1) locations(i,2) locations(i,1)+objectSize locations(i,2)+objectSize]);
                        elseif i <= items - (items/4) %Assign locations for the third quarter of distractors
                            Screen('PutImage', Arraywindow, Dist3,[locations(i,1) locations(i,2) locations(i,1)+objectSize locations(i,2)+objectSize]);
                        else %Assign locations for the fourth quarter of distractors
                            Screen('PutImage', Arraywindow, Dist4,[locations(i,1) locations(i,2) locations(i,1)+objectSize locations(i,2)+objectSize]);
                        end
                    end
                end   
            end
            
            
%--------------------------------------------------------------
% ITI/Fixation Display Cue
%--------------------------------------------------------------
            ITIbase = 1;
            ITIadd = .5;
            
            ITI = round(((rand * ITIadd) + ITIbase)/timing)*timing;
            
            Screen(window, 'FillOval', white, [CX-5 CY-5 CX+5 CY+5]);
            Screen('Flip', window);
            
            WaitSecs(ITI);
            
%---------------------------------------------------
% Presenting the Windows
%---------------------------------------------------
            Screen(window, 'FillOval', white, [CX-5 CY-5 CX+5 CY+5]);
            Screen('FrameOval', window, gray, CueLoc1,4);
            Screen('FillArc', window, gray, CueLoc1, 0, BasicAngle);
            Screen('FrameOval', window, CueStim, CueLoc2,4);
            Screen('FillArc', window, CueStim, CueLoc2, 0, WorkAngle);
            Screen(window,'TextSize', 32);
            if str2double(BasicIncomeValue) > 999
                DrawFormattedText (window, BasicIncomeValue, CueLoc1(1),CueLoc1(4)+35, white);
            else
                DrawFormattedText (window, BasicIncomeValue, CueLoc1(1)+5,CueLoc1(4)+35, white);
            end
            if str2double(WorkIncomeValue) > 999
                DrawFormattedText (window, WorkIncomeValue, CueLoc2(1), CueLoc2(4)+35, white);
            else
                DrawFormattedText (window, WorkIncomeValue, CueLoc2(1)+5, CueLoc2(4)+35, white);
            end
            
            t1=GetSecs;
            
            [VBLTimestamp, Begin_Time]=Screen('Flip', window);%flips target window, presenting target to subject, and timestamps this to use for RT calculaions below
            
            while 1 %GetSecs - t1 < 2  % wait 2 seconds and then initiate trial timeout
                [KeyIsDown, End_Time, KeyCode]=KbCheck; %notes when key is down, recording time, and notes key identity
                if KeyIsDown
                    Screen(window, 'FillRect', black);
                    Screen('Flip', window);
                    break;
                end
                WaitSecs(.0001);
            end
            
            Cue_Key = KbName(KeyCode); %find out which key was pressed
            
            RT_Cue(Trial) = (End_Time-Begin_Time)*1000;
            
%---------------------------------------------------
% Response Coding
%---------------------------------------------------
            
            if strcmp(Cue_Key,'z') %Left Cue
                Response_Cue(Trial) = 1;
            elseif strcmp(Cue_Key,'/?') %Right Cue
                Response_Cue(Trial) = 2;
            end
            
            if Response_Cue(Trial) == 1
                if CueLocation(Order(Trial)) == 1
                    Response_Choice(Trial) = 1;
                    EarnedIncome(Trial) = str2double(BasicIncomeValue);
                elseif CueLocation(Order(Trial)) == 2
                    Response_Choice(Trial) = 2;
                    EarnedIncome(Trial) = str2double(WorkIncomeValue);
                end
            elseif Response_Cue(Trial) == 2
                if CueLocation(Order(Trial)) == 1
                    Response_Choice(Trial) = 2;
                    EarnedIncome(Trial) = str2double(WorkIncomeValue);
                elseif CueLocation(Order(Trial)) == 2
                    Response_Choice(Trial) = 1;
                    EarnedIncome(Trial) = str2double(BasicIncomeValue);
                end
            end
              
%--------------------------------------------------------------
% ITI/Fixation Display Search
%--------------------------------------------------------------
            if Response_Choice(Trial) == 2 %Subject chooses the work cue            
                ITIbase = 1;
                ITIadd = .5;

                ITI = round(((rand * ITIadd) + ITIbase)/timing)*timing;

                Screen(window, 'FillOval', white, [CX-5 CY-5 CX+5 CY+5]);
                Screen('Flip', window);

                WaitSecs(ITI); 
            
%---------------------------------------------------
% Present Search Display
%---------------------------------------------------
            
                Screen('CopyWindow', Arraywindow, window, [0 0 700 700], [CX-350 CY-350 CX+350 CY+350]);
                Screen(window, 'FillOval', white, [CX-5 CY-5 CX+5 CY+5]);
                
                t2=GetSecs;
                Response_Search(Trial) = 0;

                
                [VBLTimestamp, Begin_Time]=Screen('Flip', window);%flips target window, presenting target to subject, and timestamps this to use for RT calculaions below
                
                while GetSecs - t2 < 10  % wait 10 seconds and then initiate trial timeout
                    [KeyIsDown, End_Time, KeyCode]=KbCheck; %notes when key is down, recording time, and notes key identity
                    if KeyIsDown
                        Screen(window, 'FillRect', black);
                        Screen('Flip', window);
                        break;
                    end
                    WaitSecs(.0001);
                end
                
                Search_Key = KbName(KeyCode); %find out which key was pressed
                
                RT_Search(Trial) = (End_Time-Begin_Time)*1000;
                
            
%---------------------------------------------------
% Search Response & Accuracy Coding
%---------------------------------------------------
                if strcmp(Search_Key,'z') %Left Target T
                    Response_Search(Trial) = 1;
                elseif strcmp(Search_Key,'/?') %Right Target T
                    Response_Search(Trial) = 2;
                end


                if TargetID(Order(Trial)) == 1 %Target Left
                    if Response_Search(Trial) == 1 %Button /?
                        Accuracy(Trial) = 1;
                        SearchCorrect = SearchCorrect + 1;
                    else %Button Z
                        Accuracy(Trial) = 0;
                        EarnedIncome(Trial) = 0;
                        SearchWrong = SearchWrong + 1;
                    end
                elseif TargetID(Order(Trial)) == 2 %Target Right
                    if Response_Search(Trial) == 2 %Button Z
                        Accuracy(Trial) = 1;
                        SearchCorrect = SearchCorrect + 1;
                    else %Button /?
                        Accuracy(Trial) = 0;
                        EarnedIncome(Trial) = 0;
                        SearchWrong = SearchWrong + 1;
                    end
                else
                    Accuracy(Trial) = 0;
                    EarnedIncome(Trial) = 0;
                    SearchWrong = SearchWrong + 1;
                end
            
            end
            Screen(Arraywindow, 'FillRect', black);
%-------------------------------------------------------------------
% Reward Display
%-------------------------------------------------------------------

            FeedbackText = ['+', num2str(EarnedIncome(Trial))];
            if expType == 'e'
                DrawFormattedText(window, FeedbackText, 'center', 'center', [255 255 255]);
                Screen('Flip', window);
                WaitSecs(1);
            end
                       
            Screen(window, 'FillRect', [0 0 0]);
            Screen('Flip', window);
            
            
%------------------------------------------------------------------------
% Blocks and Breaks
%------------------------------------------------------------------------
            if expType == 'e'
                if mod(Trial,40) == 0 && Trial ~= TotalTrial
                    
                    %performance feedback
                    Screen(window, 'FillRect', black);
                    OverallACC=round(SearchCorrect/(SearchCorrect+SearchWrong)*100*100)/100;
                    AccText=num2str(OverallACC);
                    CurrentScore = sum(EarnedIncome(1:Trial));
                    ScoreText=prettyprint(CurrentScore);
                    CurrentEarningsText = num2str(round(CurrentScore/100000*100)/100);
                    
                    
                    Screen(window,'TextSize', 24);
                    PerfDispBreak = ['\n\n\n\n\n\n\n\nOverall Accuracy = ', AccText, '%\n\n' ...
                        'Total Score = ', ScoreText, '\n\n' ...
                        'Total Earnings = $', CurrentEarningsText, '\n\n\n\n\n\n\n\n\n' ...
                        'Take a short break and calm yourself.\n'...
                        'When you are ready to start the next block, \n\n\n\n press SPACEBAR to continue.'];
                    DrawFormattedText(window, PerfDispBreak, 'center', 'center', [255 255 255]);
                    Screen('Flip', window);
                    
                    KbWait([],2);
                    Screen(window, 'FillRect', black);
                    Screen('Flip', window);
                    
                end
                
                if mod(Trial,40) == 1
                    Base = Base + 1;
                end
                
                Block(Trial) = Base;
            end
            
            
%-------------------------------------------------------------------
% Reaction Time & Trial Number
%-------------------------------------------------------------------
            
            ThisTrial(Trial) = Trial+TotalTrial*tt+TotalTrial/2*jj;
            BlockNumber(Trial) = jj+1;
            
%-------------------------------------------------------------------
% Print Data to File
%-------------------------------------------------------------------
            
                        if expType == 'e'
                            if (TotalTrial>=1) %starts saving data if subject has completed at least 1 trial
                                Subject(Trial) = SN;
                                FID = fopen(FileName, 'a');
                                Save = [Order(Trial); BlockNumber(Trial); Block(Trial); Condition(Trial+TotalTrial*tt); CBSelect(1); CueLocation(Order(Trial)); LevelDiff(Order(Trial)); TargetID(Order(Trial)); RelativeProp(Order(Trial)); TargetQuad(Order(Trial)); ThisTrial(Trial); Subject(Trial); Response_Cue(Trial); Response_Choice(Trial); Response_Search(Trial); IncomeMatrix(Trial,BasicIncomeLevel); IncomeMatrix(Trial,RelativeProp(Order(Trial))); EarnedIncome(Trial); Accuracy(Trial); RT_Cue(Trial); RT_Search(Trial)];
                                fprintf(FID, '%7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %3.4f, %3.4f', Save);
                                fprintf(FID,'\n');
                                fclose(FID);
                            end
                        end

        end %closes the for Trial=1:TotalTrial loop
        
        if expType == 'p'
            break
        end
        
    end %closes the for tt=0:1 loop
    
    if expType == 'p'
        break
    end
    
end %closes the for jj=0:2 loop

if expType == 'e'
    Screen(window,'TextFont', 'Helvetica');
    Screen(window,'TextSize', 24);
    EndText = ['You have completed the experiment.\n' 'Press any key to continue.'];
    DrawFormattedText (window, EndText, 'center', 'center', [255 255 255]);
    Screen('Flip', window);
    KbWait([],2);
elseif expType == 'p'
    Screen(window,'TextFont', 'Helvetica');
    Screen(window,'TextSize', 24);
    AccText = ['You completed practice with ' num2str(mean(Accuracy(1:36)*100),3) '% accuracy.'];
    DrawFormattedText (window, AccText, 'center', 'center', [255 255 255]);
    Screen('Flip', window);
    KbWait([],2);
end

ShowCursor;
Screen('CloseAll');





