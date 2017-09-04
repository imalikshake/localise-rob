function path = wavefront(graph,queue,gridSize,bot)

    target = queue(1,:);
    while (~isempty(queue))
        node = queue(1,:);
        nstr = c2str(node);

        children = [node(1)+gridSize node(2)+gridSize;
        node(1)+gridSize node(2)-gridSize;
        node(1)-gridSize node(2)-gridSize;
        node(1)-gridSize node(2)+gridSize;
        node(1) node(2)+gridSize;
        node(1) node(2)-gridSize;
        node(1)+gridSize node(2);
        node(1)-gridSize node(2)];

    
        queue(1,:) = [];
        
        for i=1:8
            children(i,:) = children(i,:);
            cstr = c2str(children(i,:));

            pvalue = gridSize*2;
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
                value = graph(nstr) + 1 +totalValue;
                if graph(cstr) == 0
                    graph(cstr) = value;
                    queue = cat(1,queue,children(i,:));
                elseif graph(cstr) > value
                    graph(cstr) = value;
                end
            end
        end
    end
%     path = start;
%     node = start;
%     while(node ~= target)
%         children = [node(1)+gridSize node(2)+gridSize;
%             node(1)+gridSize node(2)-gridSize;
%             node(1)-gridSize node(2)-gridSize;
%             node(1)-gridSize node(2)+gridSize;
%             node(1) node(2)+gridSize;
%             node(1) node(2)-gridSize;
%             node(1)+gridSize node(2);
%             node(1)-gridSize node(2)];
%         
%         min=Inf;
%         for i=1:8
%             cstr = c2str(children(i,:));
%             if  bot.pointInsideMap(children(i,:)) == 1 && graph(cstr) < min
%                 min = graph(cstr);
%                 index = i;
%             end
%         end
%         path = cat(1,path,children(index,:));
%         node = children(index,:);
%     end

%     path = cat(1,path,target);
end