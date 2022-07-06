function segyoutput(sgyfile, datain, sampint, numsamps, numtraces, format, platform)

% function segyoutput(sgyfile, datain, sampint, numsamps, numtraces, format, platform)
%
% Writes seismic data from Matlab workspace to a segy format file on disk.
% The name of the segy file and the platform must both be given in single quotes.
% 'Platform' tells Matlab to write the data in the associated machine byte
% order. The SEG-Y stadard calls for big-endian mapped files.
% Possible platform designations, quoted from the FOPEN help file in the Matlab help 
% files, most likely formats first:
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
% 'format' refers to the segy standard codes indicating data sample format code.
% Options for format are:
% 1 = 4 byte floating point, ieee
% 2 = 4 byte fixed point
% 3 = 2 byte fixed point
% 4 = fixed point with gain code (not writable with this code)
% 5 = IBM/360 32-bit floats (not writable with this code)
%
% datain    = a structured array containing four fields, textheader,
%             binaryheader, traceheaders, and data
% sampint   = sampling interval
% numsamps  = number of samples per trace
% numtraces = number of traces in the segy record
% sgyfile   = new segy format file name
% 
% Written by C. Osborne, January 2002, Revised March 2002

% Check the file name for problems.
strlength = max(size(sgyfile));
test1 = sgyfile((strlength - 3):strlength);

if (test1 ~= '.sgy') | (test1 ~= '.seg')
    disp(' ')
    disp('This data will not have a ".sgy" or ".seg" extension.')
    disp('Do you wish to continue?')
    intest = input('Type y for yes, n for no then hit the enter key.\n', 's')
    if intest == 'n'
        break
    end
end

% Close any previously opened files.
fclose('all');
% Open or create the file for writing.
fid = fopen(sgyfile, 'w', platform);

% Get the 3200 byte text header ready for writing.
temp = (datain.textheader)';
temp = ascii2ebcdic(temp);
% Write the text header.
count = fwrite(fid, temp, 'uchar');

% Check if writing went successfully.
if count ~= 3200
    error(['EBCDIC header is too short. Size is only ', num2str(count), '.']); 
else
    disp('EBCDIC header written successfully.')
end

clear temp

% Now fill in the binary header.
temp = datain.binaryheader;
temp(6:6, :) = sampint*1000000;
temp(8:8, :) = numsamps;
temp(10:10, :) = format;
test1 = temp(1:3);
test2 = temp(4:27);
test3 = zeros(170, 1);
count2 = fwrite(fid, test1, 'int32');
count3 = fwrite(fid, test2, 'int16');
count4 = fwrite(fid, test3, 'int16');

% Check if writing went successfully.
if (count2 == 3) & (count3 == 24) & (count4 == 170)
    disp('Binary header read in successfully.')
else
    error('The binary header has been truncated.')
end

clear temp
clear count*
clear test*

% Determine the units used for the survey.
units = datain.binaryheader(25:25, :);

if units == 2 % feet used
   units = 0.3048
else
   units = 1; % metres used
end

if format == 1 
	dformat = 'float32'; % 4 bytes.
elseif format == 2
    dformat = 'int32'; % 4 bytes, signed.
elseif format == 3
    dformat = 'int16'; % 2 bytes, signed.
elseif format == 4
    error('Can not write this format. (Fixed point with gain code.)');
elseif format == 5
    dformat = 'float32'; % 4 bytes
else
    error(['Can not write data format ', num2str(format), '.']);
end

% Write out the data traces and trace headers.
% Other initializations needed for the while loop.
tracewrit = 1;
trcount = 0;

while tracewrit <= numtraces
    trcount = fwrite(fid, datain.traceheaders(:, tracewrit:tracewrit), 'float32');
    
    if (format == 5) | (format == 4)
        error(['Cannot write this format ', num2str(format), '.']);
  	else
        temp = (datain.data(:, tracewrit:tracewrit))/units;
        count = fwrite(fid, temp, dformat);
        if count ~= numsamps
           error(['Problem writing trace ', num2str(tracewrit), '.'])
        else
          disp(['Trace ', num2str(tracewrit), ' written successfully.'])
        end
    end
    tracewrit = tracewrit + 1;
end

fclose(fid)
disp('Segy data written out successfully.')

