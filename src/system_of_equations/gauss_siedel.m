function [solution, iterations, data] = gauss_siedel(coeff_matrix, constants_matrix, initial_guess, max_iterations, epsilon, output_file)
    addpath('../')
    
    tic 
    system_matrix = create_system_matrix(coeff_matrix, constants_matrix);
    num_of_unknowns = length(constants_matrix);
    [solution, iterations, data] = implementation(system_matrix, initial_guess, num_of_unknowns, max_iterations, epsilon, 0, []);
    timeElapsed = toc;


    % display results in table in output file
    fileID = fopen(output_file,'w');
    colheadings = {'x', 'y', 'z', 'Err_x', 'Err_y', 'Err_z'};
    rowheadings = {};
    for i=1:iterations,
        rowheadings{end+1} = int2str(i);
    end

    fms = {'.4f','.4f', '.4f','.4f','.4f', '.4f'};
    wid = 16;
    displaytable(data, colheadings, wid, fms, rowheadings, fileID, '|', '|');

    timeElapsed = toc;
    fprintf(fileID, '\nnumber of iterations: %d\n', iterations);
    fprintf(fileID, 'execution time: %f\n', timeElapsed);
    fclose(fileID);

end



function [solution, iterations, data] = implementation(system_matrix, previous_solutions, num_of_unknowns, max_iterations, epsilon, iterations, data)
        
    current_solutions=previous_solutions;

    approximations = []
    errors = [0, 0, 0];
    for row=1:num_of_unknowns
        
        a=system_matrix(row, row);
        d=system_matrix(row, num_of_unknowns+1);
        %disp(d);
        
        summation=0;
        index=1;
        for col=1:num_of_unknowns
            if(row==col)
                index = index+1;
                continue;
            end
            %disp(col);
            %disp(system_matrix(row, col));
            summation = summation + system_matrix(row, col)*previous_solutions(index);
            index = index+1;
        end
       
        answer = (1/a)*(d-(summation));
        %disp(answer);
        current_solutions(row)=answer;

        approximations = [approximations current_solutions(row)];
        errors(row)=abs( ( current_solutions(row)-previous_solutions(row) )/ current_solutions(row) );
    end

    % data = cat(2, data, approximations, errors);
    % tmp= cat(2, approximations, errors);
    % data = cat(1, data, tmp);
    data = [data; approximations, errors];
    
    %disp(current_solutions);
    
    iterations = iterations+1;
    stop_algorithm = stop_condition_test(previous_solutions, current_solutions, max_iterations, iterations, epsilon);
    if(stop_algorithm==true)
        solution = current_solutions;
        return;
    end
    
    [solution, iterations, data] =implementation(system_matrix, current_solutions, num_of_unknowns, max_iterations, epsilon, iterations, data);


end



function test = stop_condition_test(previous_solutions, current_solutions, max_iterations, iterations, epsilon)

    if iterations>=max_iterations
        test=true;
        return;
    end


    for index=1:length(current_solutions)
        error = (current_solutions(index)-previous_solutions(index))/current_solutions(index);
        if(error>=epsilon)
            test=false;
            return;
        end
            
    end

    
    
    
end



function system_matrix = create_system_matrix(coeff_matrix, constants_matrix)
    result=coeff_matrix;
    for index=1:length(constants_matrix)
        result(index, length(constants_matrix)+1)=constants_matrix(index);
    end
    
    system_matrix=result;
    
end






