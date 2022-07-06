function [dataout, sampint, numsamps, t] = segyinput(sgyfile, platform,...
    traces, skip, fcode, ucode)

% function [dataout, sampint, numsamps, t] = segyinput(sgyfile, platform,...
%     traces, skip, fcode, ucode)
%
% Reads segy data into a structured array format in Matlab workspace.
% The name of the segy file and the platform must both be given
% in single quotes. (Without single quotes you will get an 
% "??? Undefined variable 'unquoted stuff'." error.)
%
% Segyinput also gives you the following options: specify the number of 
% traces to read in, the format of the data samples, and the units of 
% measurement used by the survey if desired. The maximum number of traces 
% that may be read in or skipped is approximately 8500 if each trace is 
% 3000 samples long and the data is stored in a 4 byte format.
%
% Possible platform designations, quoted from the FOPEN Matlab help file,
% most likely formats first:
%
% 'b' = data written in UNIX format (big endian, IEEE floating point)
% 'l' = data written in PC format (little endian, IEEE floating point)
% 'c' = Cray floating point (big endian)
% 's' = 64 bit long data type (big endian, IEEE floating point)
% 'a' = 64 bit long data type (little endian, IEEE floating point)
% 'n' = defaults to the format the machine running Matlab uses
% 'd' = VAXD floating point with VAX ordering
% 'g' = VAXG floating point with VAX ordering
%
% dataout   = a structured array containing four fields: textheader,
%             binaryheader, traceheaders, and data
% sampint   = sampling interval
% numsamps  = number of samples per trace
% t         = time vector
% traces    = optional argument, indicates number of traces to read in;
%             otherwise all traces are read in by default
% skip      = optional argument; if the number of traces being read in is 
%             specified, this allows a number of traces to be skipped before 
%             the read in begins (you may have a trace setting without a
%             skip setting, but not a skip setting without a trace setting)
% fcode     = optional argument, format code for the data
%             options for fcode are:
%             1 = 4 byte floating point
%             2 = 4 byte fixed point
%             3 = 2 byte fixed point
%             4 = fixed point with gain code (not readable with this code)
%             5 = IBM/360 32-bit floats
% ucode     = optional argument, code for unit used in the seismic survey,
%             1 for metres, 2 for feet
% 
% Written by C. Osborne, December 2001, Revised March 2002

% Check the file name for problems.
strlength = max(size(sgyfile));
test1 = sgyfile((strlength - 3):strlength);

if (test1 ~= '.sgy') | (test1 ~= '.seg')
    disp(' ')
    disp('This data does not have a ".sgy" or ".seg" extension')
    disp('and may not be segy format data. Do you wish to continue?')
    intest = input('Type y for yes, n for no then hit the enter key.\n', 's')
    if intest == 'n'
        break
    end
end
clear intest;

fileinfo = dir(sgyfile); % Fileinfo is a structured array of file information.
[ro, co] = size(fileinfo);

if ro == 0
    error(['The file ', sgyfile, ' is not in the present working directory.'])
else
    lastbyte = fileinfo.bytes; % Pull the size of the file out of fileinfo.
end

platform = lower(platform);
dataout.textheader = zeros(40, 80); % Initialize the text header.

fclose('all'); % Close any previously opened segy files.
fid = fopen(sgyfile, 'r', platform);% Open the segy file for reading.

if fid == -1
    error('Unable to open file.')
end

% Read the segy file text header.
textheader = reshape(fread(fid, 3200, 'uchar'), 80, 40);
% Convert any numbers present to text and transpose for a
% matrix containing 40 lines of 80 characters, then assign it to the 
% first cell in the array.

[y, z] = find(textheader < 0); % Set up first if condition.
[y2, z2] = find(textheader > 127); % Set up second if condition.

if (y ~= []) | (y2 ~= [])
    tabmtest = exist('tableset.m');
    tabtest = exist('table.mat');
    if (tabtest == 0) & (tabmtest == 0)
        error('The support file "tableset.m" is missing. It is required by segyinput.')
    end
    dataout.textheader = ebcchar(textheader'); % If the header is in EBCDIC format.
else
    dataout.textheader = char(textheader'); % In case the header is in ASCII format.
end

% Read out the information from the binary header that is typically available.
% Header descriptions are in header.m.
binpart1 = fread(fid, 3, 'int32'); % First section of the binary header.
binpart2 = fread(fid, 24, 'int16'); % Second section of the binary header.

% Create the binary header cell for dataout.
binpart1s = max(size(binpart1));
binpart2s = max(size(binpart2));
binrows = binpart1s + binpart2s;
dataout.binaryheader = zeros(binrows, 1);
dataout.binaryheader(1:3, :) = binpart1;
dataout.binaryheader(4:binrows, :) = binpart2;

sampint = dataout.binaryheader(6:6, :); % Sample interval in milliseconds.
numsamps = dataout.binaryheader(8:8, :); % Number of samples.

if (nargin == 5) | (nargin == 6)
    format = fcode;
else
    format = binpart2(7);
end
needibm = 0;

% Recently a format code of 5 has been added to the segy standard for
% IBM/360 32-bit floats.
% Find what format the seismic data is in.
if format == 1
    disp(' ')
    disp('Format code does not indicate whether floating point type of the data')
    disp('is IBM format or IEEE format. Please type 1 for IBM or 2 for IEEE.')
    intest = input('Type format number, then hit enter.\n', 's')
             if intest == '1'
                needibm = 1;
             end
	dformat = 'float32'; % 4 bytes.
    bytelength = 4;
elseif format == 2
    dformat = 'int32'; % 4 bytes, signed.
    bytelength = 4;
elseif format == 3
    dformat = 'int16'; % 2 bytes, signed.
    bytelength = 2;
elseif format == 4
    error('Can not convert this format. (Fixed point with gain code.)');
elseif format == 5
    dformat = 'float32'; % 4 bytes.
    bytelength = 4;
    needibm = 1;
else
    error(['Can not convert data format ', num2str(format), '.']);
end
clear intest

% Check to see if the entire data set is to be read in or not.
if (nargin >= 3) & (nargin <= 6)
    numtraces = traces;
    lastbyte = (((bytelength*numsamps) + 240)*traces) + 3600;
else
    numtraces = round(lastbyte/((bytelength*numsamps) + 240));
end

% Find what distance measurement units were used in the survey.
if nargin == 6
   units = ucode;
else
   units = dataout.binaryheader(25:25, :); % Units used for the seismic survey.
end

if units == 2 % Feet used.
 units = 0.3048; % Conversion factor to go from feet to metres.
else
 units = 1; % Metres used.
end

testth = fread(fid, 170, 'int16'); % Skip the rest of the binary header.
clear testth

% Skip a number of traces before starting the read if required.
if exist('skip') == 1
   skipbytes = (((bytelength*numsamps) + 240)*skip);
   testth = fread(fid, skipbytes, 'uchar');
   lastbyte = lastbyte + skipbytes;
end
clear testth

dataout.traceheaders = zeros(60, 1); % Initialize the traceheader cell.
dataout.data = zeros(numsamps, 1); % Initialize the data cell.
% Other initializations needed for the while loop.
setcol = 1;
temp = 0;
position = 0;

while position < lastbyte
    dataout.traceheaders(:, setcol:setcol) = fread(fid, 60, 'float32');
    if needibm == 1
	  ibm1 = fread(fid, numsamps, 'uint32');
      temp = ibm2ieee(ibm1);
      check2 = max(size(temp));
          if check2 ~= numsamps
             disp(['Problem reading trace ', num2str(setcol), '.'])
             disp('Replace with zeroes?')
             intest = input('Type y for yes, n for no then hit enter.\n', 's')
             if intest == 'y'
                disp('Replacing with zeroes.')
                dataout.data(:, setcol:setcol) = zeros(numsamps, 1);
             else
                break
             end
          else
             dataout.data(:, setcol:setcol) = temp;
          end
  	else
        temp = fread(fid, numsamps, dformat);
        check2 = max(size(temp));
        if check2 ~= numsamps
           disp(['Problem reading trace ', num2str(setcol), '.'])
           disp('Replace with zeroes?')
             intest = input('Type y for yes, n for no then hit the enter key.\n', 's')
             if intest == 'y'
                disp('Replacing with zeroes.')
                dataout.data(:, setcol:setcol) = zeros(numsamps, 1);
             else
                break
             end
        else
          dataout.data(:, setcol:setcol) = temp;
        end
    end
    setcol = setcol + 1 % Prints to show the algorithm hasn't crashed.
                        % Note that setcol will finish 1 higher than the
                        % actual number of traces.
    position = ftell(fid);
end

dataout.data = units*dataout.data; % Apply the unit factor.
t = dataout.traceheaders(36:36, 1:1):(sampint/1000000):(((numsamps - 1)*sampint)/1000000);
disp('Segy data read in successfully.')
