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

if CBSelect(1) > 4
    disp('CB value must be between 1 and 4');
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
    FileName = strcat(ID, '_AttWork_SetSize_Blocked.csv');
    if exist(FileName, 'file')
        
        resp=input(['the file ' FileName ' already exists. Do you want to overwrite it? [Type ok for overwrite]'], 's');
        if ~strcmp(resp, 'ok') %abort experiment if overwite not confirmed
            disp('Experiment aborted')
            return
        end
    end
    FID = fopen(FileName, 'w');
    fprintf(FID, 'Order, Block, CBversion, CueLocation, DifficultyLevel, TargetID, RelativeProportion, TargetQuad, Trial, Subject, Response_Cue, Response_Choice, Response_Search, BasicIncome, WorkIncome, EarnedIncome, Accuracy, RT_Cue, RT_Search\n'); %\n=enter - moves to next row
    fclose(FID);
end                              

%-------------------------------------------------------
% Setting up random seed, screen, colors, gamepad, and event code
%-------------------------------------------------------

HideCursor; %hides cursor so subjects can't see it
rng(sum(100*clock),'twister');

sysrect = get(0,'screensize');
screen = 0; %opens the main presentation window
[window,rect] = Screen('OpenWindow', screen, [0 0 0], [0 0 sysrect(3) sysrect(4)]);
Arraywindow = Screen('OpenOffscreenWindow', screen, [0 0 0], [0 0 700 700]);


CX=sysrect(3)/2;
CY=sysrect(4)/2;
 
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
InstructionText = ['\n\n\n\n\n\n\n\n\n\n\n\n\nWelcome to the Experiment!\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n' 'Press SPACEBAR to continue.'];
InstructionText2 = ['\n\n\n\n\nOn each trial you will be given a choice between two options as indicated by pie wedges\n\n'...
    'The gray wedge will award you points for an easy task\n and the colored wedge will require you to do some work in exchange for more points\n\n'...
    'The more points you earn, the more money you will recieve at the end of the experiment (up to $10 bonus)\n\n'...
    'If you choose the left option, press the "Z" button on the keyboard\n\n'...
    'If you choose the right option, press the "/?" button on the keyboard\n\n'...
    'Please respond as fast and accurately as possible\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n'...
    'Press SPACEBAR to continue'];
InstructionText3 = ['\n\n\n\n\n\nOnce you have made your choice, you will have to search for the letter "T"\n\n'...
    'The "T" will be tilted to the left or tilted to the right\n\n'...
    'Sometimes the "T" will be easy to find and other times it will be difficult to find\n\n'...
    'There will always be a "T" in the display\n\n'...
    'If the "T" is tilted to the left, then press the "Z" button on the keyobard\n\n'...
    'If the "T" is tilted to the right, then press the "/?" button on the keyboard\n\n'...
    'You will have 10 seconds to find the "T"\n\n'...
    'Please respond as fast and accurately as possible\n\n\n\n\n\n\n\n\n\n\n'...
    'Press SPACEBAR to begin'];


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

DrawFormattedText (window, InstructionText3, 'center', 'center', white);
Screen('Flip', window);
KbWait([],2);

Screen('FillRect', window, [0 0 0]);
Screen('Flip', window);

%-----------------------------------------------------------------
% Load Images
%-----------------------------------------------------------------

%Search Stimuli
Lefty = imread('Stimuli/Left_T_black.jpg');
Righty = imread('Stimuli/Right_T_black.jpg');
Dist1 = imread('Stimuli/Dist_L1_resized.jpg');
Dist2 = imread('Stimuli/Dist_L2_resized.jpg');
Dist3 = imread('Stimuli/Dist_L3_resized.jpg');
Dist4 = imread('Stimuli/Dist_L4_resized.jpg');

    
%-----------------------------------------------------------------
%  Condition Distribution
%-----------------------------------------------------------------
    TarID = 2; %X or Z
    LevDiff = 4; %Four difficulty levels (easy, med, hard, very hard)
    RelProp = 8; %Ten levels of relative value proportions
    TarQuad = 4; %Four quadrants for the target
    CueLoc = 2; %Choice cue left/right
    

    TotalTrial = TarID*LevDiff*RelProp*TarQuad*CueLoc; %512
    
           
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
        EarnedIncome = zeros(1, TotalTrial);
        BasicIncome = ceil(normrnd(200,20,1,TotalTrial))';
        MultiFactor = (1:10);
        IncomeMatrix = BasicIncome * MultiFactor;
        MaxValue = max(IncomeMatrix(:,10));
        SecondQuad = [1,2,3];
        ThirdQuad = [1,2];
        Cue_Key = zeros(1, TotalTrial);
        Search_Key = zeros(1, TotalTrial);
        Base = 0;
        
        
        for i=0 : TotalTrial-1
            
            TargetQuad(i+1) = mod(i/128, TarQuad);
            TargetQuad(i+1) = floor(TargetQuad(i+1))+1;
            
            TargetID(i+1) = mod(i/64, TarID);
            TargetID(i+1) = floor(TargetID(i+1))+1;
            
            CueLocation(i+1) = mod(i/32, CueLoc);
            CueLocation(i+1) = floor(CueLocation(i+1))+1;
            
            LevelDiff(i+1) = mod(i/8, LevDiff);
            LevelDiff(i+1) = floor(LevelDiff(i+1))+1;    
            
            RelativeProp(i+1) = mod(i/1, RelProp);
            RelativeProp(i+1) = floor(RelativeProp(i+1))+1;     
         
            Order(i+1) = i+1;
            
        end
        
        
%--------------------------------------------------------------------
% For 1:TotalTrial - to allow you to loop through the code and
% 		present multiple trials during the experiment
%--------------------------------------------------------------------
        Order = randperm(TotalTrial);
               
        for Trial = 1 : TotalTrial
            
%--------------------------------------------------------------------
%  Locations
%--------------------------------------------------------------------
            
            
            ULQuad = [20 20 340 340];
            URQuad = [360 20 680 360];
            LLQuad = [20 360 340 680];
            LRQuad = [360 360 680 680];          
                       
            CueLocationLeft = [CX-163 CY-35 CX-93 CY+35]; %Left
            CueLocationRight = [CX+93 CY-35 CX+163 CY+35]; %Right
            
%--------------------------------------------------------------------
%  Choose Difficulty Level and Cue Color Based on CBSelect
%--------------------------------------------------------------------
            %Latin Square
            %  1 2 3 4
            %1 R B G Y
            %2 B Y R G
            %3 Y G B R
            %4 G R Y B
            
            if expType == 'e'
                if CBSelect(1) == 1
                    if LevelDiff(Trial) == 1
                        CueStim = red;
                    elseif LevelDiff(Trial) == 2
                        CueStim = blue;
                    elseif LevelDiff(Trial) == 3
                        CueStim = green;
                    elseif LevelDiff(Trial) == 4
                        CueStim = yellow;
                    end
                elseif CBSelect(1) == 2
                    if LevelDiff(Trial) == 1
                        CueStim = blue;
                    elseif LevelDiff(Trial) == 2
                        CueStim = yellow;
                    elseif LevelDiff(Trial) == 3
                        CueStim = red;
                    elseif LevelDiff(Trial) == 4
                        CueStim = green;
                    end
                elseif CBSelect(1) == 3
                    if LevelDiff(Trial) == 1
                        CueStim = yellow;
                    elseif LevelDiff(Trial) == 2
                        CueStim = green;
                    elseif LevelDiff(Trial) == 3
                        CueStim = blue;
                    elseif LevelDiff(Trial) == 4
                        CueStim = red;
                    end
                    
                elseif CBSelect(1) == 4
                    if LevelDiff(Trial) == 1
                        CueStim = green;
                    elseif LevelDiff(Trial) == 2
                        CueStim = red;
                    elseif LevelDiff(Trial) == 3
                        CueStim = yellow;
                    elseif LevelDiff(Trial) == 4
                        CueStim = blue;
                    end       
                end
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
            BasicIncomeLevel = 2;
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
            point96 = repmat(point16,6,1);
            point128 = repmat(point16,8,1);
%--------------------------------------------------------------
% Select Stimulus Locations
%--------------------------------------------------------------

            if LevelDiff(Trial) == 1 % set size 32
                points = point32;
                items = 32;
            elseif LevelDiff(Trial) == 2 % set size 64
                points = point64;
                items = 64;
            elseif LevelDiff(Trial) == 3  % set size 96
                points = point96;
                items = 96;
            elseif LevelDiff(Trial) == 4  % set size 128
                points = point128;
                items = 128;                
            end
            
            locations = createPoints(points, [dx dy], 25, 20, 10000);
           

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
            Screen('FrameOval', window, gray, CueLoc1);
            Screen('FillArc', window, gray, CueLoc1, 0, BasicAngle);
            Screen('FrameOval', window, CueStim, CueLoc2);
            Screen('FillArc', window, CueStim, CueLoc2, 0, WorkAngle);
            Screen(window,'TextSize', 32);
            if str2double(BasicIncomeValue) > 999
                DrawFormattedText (window, BasicIncomeValue, CueLoc1(1),CueLoc1(4)+35, white);
            else
                DrawFormattedText (window, BasicIncomeValue, CueLoc1(1)+10,CueLoc1(4)+35, white);
            end
            if str2double(WorkIncomeValue) > 999
                DrawFormattedText (window, WorkIncomeValue, CueLoc2(1), CueLoc2(4)+35, white);
            else
                DrawFormattedText (window, WorkIncomeValue, CueLoc2(1)+10, CueLoc2(4)+35, white);
            end
            
            t1=GetSecs;
            
            [~, Begin_Time]=Screen('Flip', window);%flips target window, presenting target to subject, and timestamps this to use for RT calculaions below
            
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

    %----------------------------------------------------------------------------- Draw target and distractors
    
if Response_Choice(Trial) == 2    
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
elseif Response_Choice(Trial) == 1
    if TargetID(Order(Trial)) == 1 % Lefty Target
        Screen('PutImage', Arraywindow, Lefty,[locations(1,1) locations(1,2) locations(1,1)+objectSize locations(1,2)+objectSize]);
    elseif TargetID(Order(Trial)) == 2 % Righty Target
        Screen('PutImage', Arraywindow, Righty,[locations(1,1) locations(1,2) locations(1,1)+objectSize locations(1,2)+objectSize]);
    end  
else
     %Screen('PutImage', Arraywindow, Lefty,[locations(1,1) locations(1,2) locations(1,1)+objectSize locations(1,2)+objectSize]);
    NoChoiceText = ['Improper response registered!\n\n'...
                    'Please used the appropriate response keys.\n\n\n\n\n\n'...
                    'Press SPACEBAR to continue.'];
    DrawFormattedText(Arraywindow, NoChoiceText, 'center', 'center', [255 255 255]);  
end
            
            
%--------------------------------------------------------------
% ITI/Fixation Display Search
%--------------------------------------------------------------
        
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
                
            if Response_Choice(Trial) > 0  %Subject actually makes a choice 
                Screen(window, 'FillOval', white, [CX-5 CY-5 CX+5 CY+5]);
            end
                
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
                    else %Button Z
                        Accuracy(Trial) = 0;
                        EarnedIncome(Trial) = 0;
                    end
                elseif TargetID(Order(Trial)) == 2 %Target Right
                    if Response_Search(Trial) == 2 %Button Z
                        Accuracy(Trial) = 1;
                    else %Button /?
                        Accuracy(Trial) = 0;
                        EarnedIncome(Trial) = 0;
                    end
                else
                    Accuracy(Trial) = 0;
                    EarnedIncome(Trial) = 0;
                end
            
            %end
            Screen(Arraywindow, 'FillRect', black);
%-------------------------------------------------------------------
% Reward Display
%-------------------------------------------------------------------

            FeedbackText = ['+ ', num2str(EarnedIncome(Trial))];
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
                if mod(Trial,32) == 0
                    
                    %performance feedback
                    Screen(window, 'FillRect', black);
                    RunACC=mean(Accuracy(1:Trial))*100;
                    AccText=num2str(RunACC);
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
                
                if mod(Trial,32) == 1
                    Base = Base + 1;
                end
                
                Block(Trial) = Base;
            end
            
            
%-------------------------------------------------------------------
% Reaction Time & Trial Number
%-------------------------------------------------------------------
            
            ThisTrial(Trial) = Trial;
            
%-------------------------------------------------------------------
% Print Data to File
%-------------------------------------------------------------------
            
                        if expType == 'e'
                            if (TotalTrial>=1) %starts saving data if subject has completed at least 1 trial
                                Subject(Trial) = SN;
                                FID = fopen(FileName, 'a');
                                Save = [Order(Trial); Block(Trial); CBSelect(1); CueLocation(Order(Trial)); LevelDiff(Trial); TargetID(Order(Trial)); RelativeProp(Order(Trial)); TargetQuad(Order(Trial)); ThisTrial(Trial); Subject(Trial); Response_Cue(Trial); Response_Choice(Trial); Response_Search(Trial); IncomeMatrix(Trial,BasicIncomeLevel); IncomeMatrix(Trial,RelativeProp(Order(Trial))); EarnedIncome(Trial); Accuracy(Trial); RT_Cue(Trial); RT_Search(Trial)];
                                fprintf(FID, '%7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %7d, %3.4f, %3.4f', Save);
                                fprintf(FID,'\n');
                                fclose(FID);
                            end
                        end

        end %closes the for Trial=1:TotalTrial loop
        

Screen(window,'TextFont', 'Helvetica');
Screen(window,'TextSize', 24);
EndText = ['You have completed the experiment.\n' 'Press any key to continue.'];
DrawFormattedText (window, EndText, 'center', 'center', [255 255 255]);
Screen('Flip', window);
KbWait([],2);

ShowCursor;
Screen('CloseAll');





