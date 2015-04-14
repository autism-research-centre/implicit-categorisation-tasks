function category_stimuli(ID_num)
try  

rng('shuffle');
eeg_switch = 0;

task_type = 'A';

if eeg_switch == 1
    config_io;
end

if nargin<1
    ID_num = input('Participant ID? ', 's');
end

tstamp = clock;
savefile = fullfile(pwd, 'Results', [sprintf('categorisation-%02d-%02d-%02d-%02d%02d-%s-', tstamp(1), tstamp(2), tstamp(3), tstamp(4), tstamp(5)), ID_num, task_type, '.txt']);
savefile_answers = fullfile(pwd, 'Results', [sprintf('categorisation-%02d-%02d-%02d-%02d%02d-%s-', tstamp(1), tstamp(2), tstamp(3), tstamp(4), tstamp(5)), ID_num, task_type, '_ANSWERS.txt']);

row_trials = 'Trial';
response_trial = 'Key';

fileID = fopen(savefile,'wt+');
fprintf(fileID,'Trial\tKey\tTriplet\tCategory\tImage\tCR\tPP\n');
fileID_ANS = fopen(savefile_answers,'wt+');
fprintf(fileID_ANS,'Response\tImage_1\tImage_2\tImage_3\tImage_4\tImage_5\tImage_6\tSeq_a\tSeq_b\tPP_a\tPP_b\tCR\n');
  
Screen('Preference', 'SkipSyncTests', 1);  

%% Experiment Variables.
scr_background = 127.5;
scr_no = 0;
white = WhiteIndex(scr_no);
black = BlackIndex(scr_no);
pp_address = hex2dec('D010');

if eeg_switch == 1
    outp(pp_address, 0);
end


scr_dimensions = Screen('Rect', scr_no);

xcen = scr_dimensions(3)/2;
ycen = scr_dimensions(4)/2;
xfull = scr_dimensions(3);
yfull = scr_dimensions(4);

% Set up Keyboard
WaitSecs(1);
KbName('UnifyKeyNames');
left_key = KbName('LeftArrow');
right_key = KbName('RightArrow');
esc_key = KbName('Escape');
space_key = KbName('space');
yes_key = KbName('y');
no_key = KbName('n');
keyList = zeros(1, 256);
keyList([yes_key, no_key, left_key, right_key, esc_key, space_key]) = 1;
KbQueueCreate([], keyList); clear keyList

% Sound
InitializePsychSound;
pa = PsychPortAudio('Open', [], [], [], [], [], 256);
bp400 = PsychPortAudio('CreateBuffer', pa, [MakeBeep(400, 0.2); MakeBeep(400, 0.2)]);
PsychPortAudio('FillBuffer', pa, bp400);

% Open Window

scr = Screen('OpenWindow', scr_no, scr_background);

HideCursor;

Screen('TextFont', scr, 'Ariel');
Screen('TextSize', scr, 40);
Screen('BlendFunction', scr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Priority(1);

count_text = 'The task will start in';
countdown_pause(5, count_text);

testing_instructions;

text_screen('Press SPACEBAR to start');

testing_phase;

debrief;

%% Shutdown
fclose(fileID);
fclose(fileID_ANS);
DrawFormattedText(scr, 'Thank you!', 'center', 'center', 0);
Screen('Flip', scr);
WaitSecs(2);
%save(savefile);
KbQueueStop;
PsychPortAudio('Close');
sca;
Priority(0);
disp('All done!');

catch errMessage
      KbQueueStop;
    sca;
    rethrow(errMessage);
    
end



%% Subfunctions

function outp(address,byte)

        global cogent;

        %test for correct number of input arguments
        if(nargin ~= 2)
            error('usage: outp(address,data)');
        end

        io64(cogent.io.ioObj,address,byte);

end

function config_io

        global cogent;

        %create IO64 interface object
        cogent.io.ioObj = io64();

        %install the inpoutx64.dll driver
        %status = 0 if installation successful
        cogent.io.status = io64(cogent.io.ioObj);
        
        if(cogent.io.status ~= 0)
            disp('inp/outp installation failed!')
        end

end

function testing_phase
    

    test_data = read_mixed_csv('test_trials.csv',',');
    shuffled_data = test_data(randperm(size(test_data,1)),:);

    for row_trials = 1:32 
            
       image_one_val = shuffled_data{row_trials,1};
       image_two_val = shuffled_data{row_trials,2};
       image_three_val = shuffled_data{row_trials,3};
       image_four_val = shuffled_data{row_trials,4};
       image_five_val = shuffled_data{row_trials,5};
       image_six_val = shuffled_data{row_trials,6};
       seq_a = shuffled_data{row_trials,7};
       seq_b = shuffled_data{row_trials,8};
       pp_a = shuffled_data{row_trials,9};
       pp_b = shuffled_data{row_trials,10};
       correctresponse = shuffled_data{row_trials,11};
       pp_a_num = str2num(pp_a);
       pp_b_num = str2num(pp_b);
       
       image_one_full = fullfile(pwd, 'Scene_Pictures', image_one_val);
       image_two_full = fullfile(pwd, 'Scene_Pictures', image_two_val);
       image_three_full = fullfile(pwd, 'Scene_Pictures', image_three_val);
       image_four_full = fullfile(pwd, 'Scene_Pictures', image_four_val);
       image_five_full = fullfile(pwd, 'Scene_Pictures', image_five_val);
       image_six_full = fullfile(pwd, 'Scene_Pictures', image_six_val);
   if eeg_switch == 1    
   outp(pp_address, pp_a_num);
   WaitSecs(0.001);
   outp(pp_address, 0);
   end
   
   show_img(image_one_full);
   show_img(image_two_full);
   show_img(image_three_full);
   Screen('Flip', scr);
   fixation_cross;
    WaitSecs(0.7);
    Screen('Flip', scr);
    WaitSecs(0.3);
    if eeg_switch == 1
    outp(pp_address, pp_b_num);
   WaitSecs(0.001);
   outp(pp_address, 0);
    end
    
   show_img(image_four_full);
   show_img(image_five_full);
   show_img(image_six_full);
   Screen('Flip', scr);
    WaitSecs(1);
    Line1 = 'Which was more familiar?';
    dottedline = '------------------------';
    Line2 = 'Press left for the 1st sequence or right for the 2nd sequence';
    Line3 = '    <--                                     -->       ';
    Line4 = '    1st                                     2nd       ';
    
    if row_trials < 3
            text_string = sprintf('%s\n%s\n\n%s\n\n%s\n%s', Line1, dottedline, Line2, Line3, Line4);
    else
        text_string = sprintf('%s\n%s', Line3, Line4);
    end
    
    DrawFormattedText(scr, text_string, 'center', 'center', 0);
        Screen('Flip', scr);

        KbQueueStart();    
   
waitTime    = 20;        

startTime = GetSecs();
pass_var = 0;

while 1
    
    keyboard_response = 'null';
    RestrictKeysForKbCheck([left_key, right_key, esc_key]);
    [ ~, firstPress]=KbQueueCheck;
    
    if firstPress(esc_key)
         error('You interrupted the script by pressing Escape after exposure');
     
    
    elseif firstPress(left_key)
         disp('You pressed Left');
        keyboard_response = 'Left';
        WaitSecs(0.5);
        pass_var = 1;
        
    elseif firstPress(right_key)
       disp('You pressed Right');
        keyboard_response = 'Right';
        WaitSecs(0.5);
        pass_var = 1;
           
    elseif GetSecs()-startTime > waitTime
       keyboard_response = 'Timeout';
        WaitSecs(0.5); 
        pass_var = 1;
        
   end

if pass_var == 1
    disp ('passed');
    fprintf(fileID_ANS,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t\n', keyboard_response, image_one_val, image_two_val, image_three_val, image_four_val, image_five_val, image_six_val, seq_a, seq_b, pp_a, pp_b, correctresponse);
    
        WaitSecs(0.5); 
    break
end
     
        
end

RestrictKeysForKbCheck([]);
KbQueueStop();
disp('Testing');
disp(keyboard_response);

%fprintf(fileID_ANS,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', keyboard_response, image_one_val, image_two_val, image_three_val, image_four_val, image_five_val, image_six_val, seq_a, seq_b, pp_a, pp_b, correctresponse);
  
    
end
end

function fixation_cross
        
        fixCrossDimPix = 40;

        xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
        yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
        allCoords = [xCoords; yCoords];


        lineWidthPix = 4;

        Screen('DrawLines', scr, allCoords,lineWidthPix, black, [xcen ycen], 2);
        Screen('Flip', scr);

end

function text_screen(text_string)
      
        RestrictKeysForKbCheck([space_key]);
        DrawFormattedText(scr, text_string, 'center', 'center', 0);
        Screen('Flip', scr);
        KbWait;
        WaitSecs(1);
        
end

function centered_text(text_string)
        
        RestrictKeysForKbCheck([space_key]);
    
        DrawFormattedText(scr, text_string, 'center', 'center', 0);
       
        Screen('TextSize', scr, 20);
        Screen('BlendFunction', scr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        text_string = 'Press the SPACEBAR to continiue';
        DrawFormattedText(scr, text_string, 'center', yfull-100, 0);
        Screen('TextSize', scr, 40);
        Screen('BlendFunction', scr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        Screen('Flip', scr);
        KbWait;
        WaitSecs(1);
        
end

function debrief
    
        Line1 = 'The task is now complete.';
        Line2 = 'Please tell the experimenter that you are finished.';
        output_full = sprintf('%s\n\n%s', Line1, Line2);
        
        centered_text(output_full);
    
    
end
   
function training_instructions
        
        Line1 = 'The following task is designed to measure';
        Line2 = 'how well you pay attention to visual scenes.';
        output_full = sprintf('%s\n\n%s\n\n%s', Line1, Line2);
        
        centered_text(output_full);
        
        Line1 = 'You will be shown a stream of images.';
        Line2 = 'Your task is to look at each image carefully';
        Line3 = 'and to press the SPACEBAR when you see the same image twice in a row.';
        output_full = sprintf('%s\n\n%s\n\n%s', Line1, Line2, Line3);
        
        centered_text(output_full);
        
        Line1 = 'If you miss a duplicate or press the SPACEBAR';
        Line2 = 'at the wrong time, you will hear a beeping sound.';
        output_full = sprintf('%s\n\n%s\n\n%s', Line1, Line2);
        
        centered_text(output_full);
        
        Line1 = 'There will be 5 blocks in total.';
        Line2 = 'Each block will last approximately 3 minutes';
        Line3 = 'and will be followed by a short break.';
        output_full = sprintf('%s\n\n%s\n\n%s', Line1, Line2, Line3);
        
        centered_text(output_full);
        
        output_full = 'Before the main task, there will be a short practice trial.';
        
        centered_text(output_full);
        
end

function testing_instructions
    
        Line1 = 'This task is deigned to assess the familiarity of sequences of images.';
        Line2 = 'The images and sequences are related to the ones from the earlier task.';
        Line3 = 'You will be asked to indicate which sequences feel more or less familiar to you.';

        output_full = sprintf('%s\n\n%s\n\n%s', Line1, Line2, Line3);
        
        centered_text(output_full);
    
        Line1 = 'You will now be shown two three-image sequences.';
        Line2 = 'A cross will indicate the end of the 1st sequence and start of the 2nd.';
        Line3 = 'You will then be asked to choose which sequence felt more familiar to you.';

        output_full = sprintf('%s\n\n%s\n\n%s', Line1, Line2, Line3);
        
        centered_text(output_full);
        
        Line1 = 'Watch the two sequences carefully';
        Line2 = 'and wait until you have seen both sequences';
        Line3 = 'before making your final decision!';
        output_full = sprintf('%s\n\n%s\n\n%s', Line1, Line2, Line3);
        
        centered_text(output_full);
        
        Line1 = 'Even if you do not find either of the two sequences very familiar';
        Line2 = 'try to use your instinct to decided between the two.';
        output_full = sprintf('%s\n\n%s\n\n%s', Line1, Line2);
        
        centered_text(output_full);
        
        Line1 = 'There will be 32 questions in total';
        Line2 = 'and you will have a maximum of 30s to respond to each question.';
        output_full = sprintf('%s\n\n%s\n\n%s', Line1, Line2);
        
        centered_text(output_full);
        
        output_full = 'If you have any questions please ask the experimenter now.';
        
        centered_text(output_full);
        
end

function training_demo

    
       for row_trials = 1:60

            KbQueueStart(); 
 
            data_train_demo = read_mixed_csv('trial_demo_order.csv',',');  
            
            image_val = data_train_demo{row_trials,1};
            duplicate_val = data_train_demo{row_trials,2}
            
            image = fullfile(pwd, 'Demo_Pictures', image_val);
            
            show_img(image);
   [ ~, firstPress]=KbQueueCheck;
    
    if firstPress(esc_key)
         disp('You interrupted the script by pressing Escape after exposure');
         break
     elseif sum(firstPress>0)
       disp('Key was pressed!')
       response_trial = '1';
       
   else
       disp('No key')
       response_trial = '0';
    end
   
    if response_trial ~= duplicate_val 
                    
         PsychPortAudio('Start', pa);
        
    end
    
  
        KbQueueStop;
    
       end
       
         Screen('Flip', scr);
    WaitSecs(1);
    
    Line1 = 'Do you want to repeat the demo?';
    dottedline = '------------------------------';
    Line2 = '(y)es or (n)o?';
    text_string = sprintf('%s\n%s\n\n%s', Line1, dottedline, Line2);
    DrawFormattedText(scr, text_string, 'center', 'center', 0);
        Screen('Flip', scr);

        KbQueueStart();    
   
waitTime    = 30;        

startTime = GetSecs();
pass_var = 0;

while 1
    
    keyboard_response = 'null';
    RestrictKeysForKbCheck([yes_key, no_key]);
    [ ~, firstPress]=KbQueueCheck;
    
    if firstPress(yes_key)
        training_demo;
        
    elseif firstPress(no_key)
       break
           
    elseif GetSecs()-startTime > waitTime
       break
        
   end
       
end


    
end

    function training_loop(start_num, finish_num, data)

        cr_input = '0';
        WaitSecs(0.5);
        
        for row_trials = start_num:finish_num

    
   KbQueueStart(); 
 
       
       
       triplet_val = data{row_trials,1};
       cat_val = data{row_trials,2};
       image_val = data{row_trials,3};
       cr_val = data{row_trials,4};
       pp_val = data{row_trials,5};
       pp_num = str2num(pp_val);
       
       image = fullfile(pwd, 'Scene_Pictures', image_val);
   
   if eeg_switch == 1    
   outp(pp_address, pp_num);
   WaitSecs(0.001);
   outp(pp_address, 0); 
   end
   
   show_img(image);
   [ ~, firstPress]=KbQueueCheck;
    
    if firstPress(esc_key)
         error('You interrupted the script by pressing Escape after exposure');
     elseif sum(firstPress>0)
       disp('Key was pressed!')
       response_trial = 'Yes'
       cr_input = '1';
       
   else
       disp('No key')
       response_trial = 'No'
       cr_input = '0';
    end
  
    
        KbQueueStop;
        
        if cr_input ~=  cr_val
            
         PsychPortAudio('Start', pa);
        
    end
            
    fprintf(fileID,'%d\t%s\t%s\t%s\t%s\t%s\t%s\n',row_trials,response_trial, triplet_val, cat_val, image_val, cr_val, pp_val);
    
        disp(savefile);
     
end
        
        
end



function training_phase
       
        data = read_mixed_csv('trial_order1.csv',',');    
    
        training_loop(1, 154, data);
       
        count_text = 'Pause for';
        countdown_pause(30, count_text);
        Line1 = 'Block 1 of 5 complete!'
        Line2 = 'Press SPACEBAR to start the next block.'
        text_string = sprintf('%s\n\n%s', Line1, Line2);
        text_screen(text_string);
        
        training_loop(155, 307, data);
        
        WaitSecs(1);
       
        countdown_pause(30, count_text);

        Line1 = 'Block 2 of 5 complete!'
        Line2 = 'Press SPACEBAR to start the next block.'
        text_string = sprintf('%s\n\n%s', Line1, Line2);
        text_screen(text_string);
        
        training_loop(308, 462, data);
        
        WaitSecs(1);
       
        countdown_pause(30, count_text);

       Line1 = 'Block 3 of 5 complete!'
        Line2 = 'Press SPACEBAR to start the next block.'
        text_string = sprintf('%s\n\n%s', Line1, Line2);
        text_screen(text_string);
        
        training_loop(463, 615, data);
        
        WaitSecs(1);
       
        countdown_pause(30, count_text);

        Line1 = 'Block 4 of 5 complete!'
        Line2 = 'Press SPACEBAR to start the next block.'
        text_string = sprintf('%s\n\n%s', Line1, Line2);
        text_screen(text_string);
        
        training_loop(615, 770, data);
        
        WaitSecs(1);
 
        
        
       
       
           
    end

function countdown_pause(time_loop, text_string)
    
    image = fullfile(pwd, 'Pictures', sprintf('%d.jpg', randi(50)));
    temp_image = imread(image, 'jpg');
    temp_texture = Screen('MakeTexture', scr, temp_image);
    
    KbQueueStart;
    for h = 1:time_loop
        time_max = time_loop + 1;
    msg = sprintf('%s %d s', text_string, time_max-h);
    DrawFormattedText(scr, msg, 'center', 0, 0);
    Screen('DrawTexture', scr, temp_texture);
    Screen('Flip', scr);
    WaitSecs(1);
        [~, first_press] = KbQueueCheck;
        if first_press(esc_key)
            error('You interrupted the script by pressing Escape after exposure');
        elseif first_press(space_key)
            break
        end
    end

    Screen('Flip', scr);
    KbQueueStop;
    RestrictKeysForKbCheck([left_key, right_key, space_key]);
    WaitSecs(1);

end


function lineArray = read_mixed_csv(fileName,delimiter)
  fid = fopen(fileName,'r');   
  lineArray = cell(100,1);     
                               
  lineIndex = 1;               
  nextLine = fgetl(fid);       
  while ~isequal(nextLine,-1)         
    lineArray{lineIndex} = nextLine;  
    lineIndex = lineIndex+1;          
    nextLine = fgetl(fid);            
  end
  fclose(fid);                 
  lineArray = lineArray(1:lineIndex-1);  
  for iLine = 1:lineIndex-1              
    lineData = textscan(lineArray{iLine},'%s',...  
                        'Delimiter',delimiter);
    lineData = lineData{1};              
    if strcmp(lineArray{iLine}(end),delimiter)  
      lineData{end+1} = '';                     
    end
    lineArray(iLine,1:numel(lineData)) = lineData;  
  end
end  

    function [image, trial_no] = get_img
            
      image = fullfile(pwd, 'Pictures', sprintf('%d.jpg', randi(50)));       
      trial_no = 7;
            
    end    
    
function show_img(image) 
    
   
    temp_image = imread(image, 'jpg');
    [s1, s2, s3] = size(temp_image);
    aspectRatio = s2 / s1;
    imageHeight = 284; 
    imageWidth = 284;
    
    temp_texture = Screen('MakeTexture', scr, temp_image);
    KbQueueStart;
    theRect = [0 0 imageWidth imageHeight];
    szRect = CenterRectOnPointd(theRect, xcen, ycen);
    Screen('DrawTexture', scr, temp_texture, [], szRect);
    Screen('Flip', scr);
          WaitSecs(0.3);       
    Screen('Flip', scr);
    WaitSecs(0.7);
    KbQueueStop;
    
end

end   
  
