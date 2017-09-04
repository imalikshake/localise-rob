function [matrix] = printWaves(graph,gridSize)
    matrix = zeros(length(1:gridSize:107),length(1:gridSize:106),'double');
    for y=1:gridSize:107   
        for x=1:gridSize:106
            coord = [x-1 y-1];
            str = c2str(coord);
            if graph.isKey(str) == 1
                matrix(floor(x/gridSize)+1,floor(y/gridSize)+1) = graph(str);
            end
        end
    end
    disp(matrix);
end

