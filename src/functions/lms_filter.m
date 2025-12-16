function [filtered_signal, estimated_artifact] = lms_filter(primary_signal, reference_signal, order, mu)
    
    num_samples = length(primary_signal);
    w = zeros(order, 1);
    
    estimated_artifact = zeros(num_samples, 1);
    filtered_signal = zeros(num_samples, 1);
    
    ref_padded = [zeros(order-1, 1); reference_signal(:)];
    
    for n = 1:num_samples
        x_n_reversed = ref_padded(n:n+order-1);
        x_n = x_n_reversed(end:-1:1);

        y_n = w' * x_n;
        
        d_n = primary_signal(n);
        e_n = d_n - y_n;
        
        w = w + mu * e_n * x_n;
        
        estimated_artifact(n) = y_n;
        filtered_signal(n) = e_n;
    end
end