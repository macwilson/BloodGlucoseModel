function normVec = normVector(origMatrix)
    % calculate the distance vector of a given matrix, into a vector
	
    len = size(origMatrix, 1);
    normVec = zeros(len, 1);
    for x = 1:len
        normVec(x) = norm(origMatrix(x, :));
    end
