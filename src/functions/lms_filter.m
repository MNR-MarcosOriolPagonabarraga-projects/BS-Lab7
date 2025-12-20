function [filtered_signal, estimated_artifact] = lms_filter(primary_signal, reference_signal, order, mu, initial_weights)
    
    if nargin < 5 || isempty(initial_weights)
        init_cond = 0;
    else
        init_cond = initial_weights;
    end

    lms_obj = dsp.LMSFilter('Length', order, ...
                            'Method', 'LMS', ...
                            'StepSize', mu, ...
                            'InitialConditions', init_cond);

    [estimated_artifact, filtered_signal] = lms_obj(reference_signal, primary_signal);
end