function c = str2c(coord)
    coordinate = strsplit(coord,',');

    x = cell2mat(coordinate(1));
    y = cell2mat(coordinate(2));
    c = [str2num(x) str2num(y)];
end