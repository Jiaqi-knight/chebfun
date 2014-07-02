function [newTree, derTree] = splitTree(tree, maxOrder)
% Isolate where the highest order derivative appears.

% If the highest order derivative is lower than the maximum order of
% the overall expression, we don't need to investigate it further.
if ( ~isstruct(tree) || tree.diffOrder < maxOrder )
    newTree = tree;
    derTree = [];
else
    switch tree.numArgs
        case 1
            % We're dealing with a unary operator, 
            [newTree, derTree] = splitTree(tree, maxOrder);
            
        case 2
            if ( any(strcmp(tree.method, {'diff','times'})) )
                newTree = [];
                derTree = tree;
            else
                [newTreeLeft, derTreeLeft] = ...
                    treeVar.splitTree(tree.left, maxOrder);
                [newTreeRight, derTreeRight] = ...
                    treeVar.splitTree(tree.right, maxOrder);
                
                if ( isempty(newTreeLeft) )
                    newTree = oneTreeFromRight(newTreeRight, tree.method);
                elseif (isempty(newTreeRight) )
                    newTree = newTreeLeft;
                else
                    if ( ~isstruct(newTreeLeft) )
                        newDiffOrder = newTreeRight.diffOrder;
                    elseif ( ~isstruct(newTreeRight) )
                        newDiffOrder = newTreeLeft.diffOrder;
                    else
                        newDiffOrder = max(newTreeLeft.diffOrder, ...
                            newTreeRight.diffOrder);
                    end
                    
                    newTree = struct('method', tree.method, ...
                        'numArgs', tree.numArgs, ...
                        'left', newTreeLeft, 'right', newTreeRight, ...
                        'diffOrder', newDiffOrder);
                end
                
                if ( isempty(derTreeLeft) )
                    derTree = oneTreeFromRight(derTreeRight, tree.method);
                elseif (isempty(derTreeRight) )
                    derTree = derTreeLeft;
                else
                    derTree = struct('method', tree.method, ...
                        'numArgs', tree.numArgs, ...
                        'left', derTreeLeft, 'right', derTreeRight, ...
                        'diffOrder', max(derTreeLeft.diffOrder, ...
                        derTreeRight.diffOrder));
                end
                
            end
    end
end
end

function ot = oneTreeFromRight(tree, operator)
if ( strcmp(operator,'minus') )
    ot = struct('method', 'uminus', 'numArgs', 1, 'center', tree, ...
        'diffOrder', tree.diffOrder);
else
    ot = tree;
end
end