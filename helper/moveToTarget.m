function [nextMove] = moveToTarget(start,graph,gridSize,bot,target,botScan)
    rstart = round(start,-1);
    diff = start - rstart;
    node = round(rstart/ gridSize) * gridSize;

    children = [node(1)+gridSize node(2)+gridSize;
        node(1)+gridSize node(2)-gridSize;
        node(1)-gridSize node(2)-gridSize;
        node(1)-gridSize node(2)+gridSize;
        node(1) node(2)+gridSize;
        node(1) node(2)-gridSize;
        node(1)+gridSize node(2);
        node(1)-gridSize node(2)];
    
    min=Inf;
    nextMove = start;
    for i=1:8
    cstr = c2str(children(i,:));
    pvalue = gridSize;
    p = children(i,:);
    padding = [p(1)+pvalue p(2)+pvalue;
    p(1)+pvalue p(2)-pvalue;
    p(1)-pvalue p(2)-pvalue;
    p(1)-pvalue p(2)+pvalue;
    p(1) p(2)+pvalue;
    p(1) p(2)-pvalue;
    p(1)+pvalue p(2);
    p(1)-pvalue p(2)];
    totalBool = bot.pointInsideMap(padding);
    totalValue = 8 - sum(totalBool);
    

        if  bot.pointInsideMap(children(i,:)) == 1 
            if graph(cstr) < min
                value = graph(cstr)+totalValue;
                if i < 5
                    value = value + 1;
                end
                if value < min
                    min = value;
                    index = i;
                    nextMove = children(index,:) + diff;
                end
            end
        end
    end
    
    
end

