%% Title: A Versatile, Energy-Efficient, and Biocompatible Pulsatile Acoustofluidic Device for Enhanced Mixing, Molecular Interactions, and Particle Manipulation
% Code By: Ali Pourabdollah Vardin, Faruk Aksoy, and Gurkan Yesiloz
%  Date: 24.02.2025
%% Video
video = VideoReader("Add your own video directory");
totalFrames = video.NumFrames; 
frameRate = video.FrameRate; % Frame rate of the video (fps)
disp(['Total Number of Frames: ', num2str(totalFrames)]);
disp(['Frame Rate (fps): ', num2str(frameRate)]);

%% Show the first frame to allow the user to determine the reference point
firstFrame = readFrame(video);
imshow(firstFrame);
title('First Frame - Click to Draw a Line');

% Draw the line manually
h = drawline;

% Get the start and end points of the line drawn by the user
pos = h.Position;

% Get the starting point selected by the user (x1, y1)
x1 = pos(1, 1); % X coordinate of the starting point
y1 = pos(1, 2); % Y coordinate of the starting point

% Calculate the endpoint of the line (adjusting 600 pixels forward)
x2 = x1 + 597; % Move forward 600 pixels
y2 = y1;       % Y coordinate remains the same (horizontal line)

% Offset distance for parallel lines
offset = 1; % Distance between lines (pixels)
num_lines = 200; % Number of parallel lines
hold on;
for i = -floor(num_lines/2):floor(num_lines/2)
    % Apply y offset for parallel lines
    y_offset = i * offset;
    % Draw the line
    plot([x1, x2], [y1 + y_offset, y2 + y_offset], 'r-', 'LineWidth', 1); 
end
hold off;

% MI calculations for all frames
MI_values = zeros(1, totalFrames); % Store MI values
time = (0:totalFrames-1) / frameRate; % Time axis (in seconds)
frameIdx = 1;

while hasFrame(video)
    %% Gray Scale and Intensity
    currentFrame = readFrame(video); % Read the current frame
    grayFrame = rgb2gray(currentFrame); % Convert to grayscale
    
    %% Get Intensity Values of Parallel Lines
    lineLength = abs(x2 - x1) + 1; % Line length
    xCoords = round(linspace(x1, x2, lineLength)); % X coordinates

    % Cell matrix to store intensity values of parallel lines
    intensitiesAllLines = cell(num_lines, 1);

    for lineIdx = 1:num_lines
        yOffset = (lineIdx - ceil(num_lines / 2)) * offset; % Apply offset
        yCoords = round(linspace(y1 + yOffset, y2 + yOffset, lineLength)); % Y coordinates

        intensities = zeros(1, lineLength); % Store intensity values
        for i = 1:lineLength
            intensities(i) = grayFrame(yCoords(i), xCoords(i)); % Grayscale values
        end
        intensitiesAllLines{lineIdx} = intensities;
    end

    %% Calculate the Average Intensity of Parallel Lines
    averageIntensity = zeros(1, lineLength); % Initialize for average intensity

    for lineIdx = 1:num_lines
        averageIntensity = averageIntensity + intensitiesAllLines{lineIdx};
    end

    averageIntensity = averageIntensity / num_lines;

    %% MI Calculation
    overallAverageIntensity = mean(averageIntensity);
    toplam = 0;

    for i = 1:length(averageIntensity)
        a = averageIntensity(i) - overallAverageIntensity; % Calculate deviation
        square_a = a^2; % Square of deviation
        toplam = toplam + square_a; % Sum the squares
    end

    result = sqrt(toplam / length(averageIntensity)); % Square root of mean square deviation
    result_2 = result / overallAverageIntensity;
    MI = 1 - result_2;

    % Save MI value
    MI_values(frameIdx) = MI;
    frameIdx = frameIdx + 1;
end

%% Visualizing Results
disp('MI values have been calculated for all frames.');
figure;
plot(time, MI_values, 'LineWidth', 1.5);
xlabel('Time (seconds)');
ylabel('MI (Mixing Intensity)');
title('MI vs. Time');
grid on;
%% 
%% Saving Results to Excel
outputData = [time(:), MI_values(:)]; % Combine time and MI values
fileName = "Give a name to your file.xlsx"; % File name
outputFile = fullfile("Directory where data to be saved", fileName); % Combine file path and name
writematrix(outputData, outputFile, 'Sheet', 1, 'Range', 'A1');
disp(['MI values have been saved to: ', outputFile]);
