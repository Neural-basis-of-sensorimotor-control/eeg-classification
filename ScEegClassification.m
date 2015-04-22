classdef ScEegClassification < handle
    properties
        N
        dt
        timepoints
        vvalues
        filter
        tag
    end
    methods
        function obj = ScEegClassification(N, dt)
            obj.filter = ScSignalFilter(obj);
            obj.vvalues = [];
            obj.timepoints = [];
            obj.dt = dt;
            obj.N = N;
            obj.tag = 'EEG_classification';
        end
        function set_v(obj, t, val)
            obj.timepoints = [obj.timepoints; t];
            obj.vvalues = [obj.vvalues; val];
            [obj.timepoints, ind] = sort(obj.timepoints);
            obj.vvalues = obj.vvalues(ind);
        end
        
        function v = sc_loadsignal(obj)
            v = -10*ones(obj.N,1);
            prev_ind = 1;
            prev_val = -10;
            for k=1:length(obj.timepoints)
                ind = floor(obj.timepoints(k)/obj.dt)+1;
                v(prev_ind:ind) = prev_val*ones(ind-prev_ind+1,1);
                prev_ind = ind+1;
                prev_val = obj.vvalues(k);
            end
            v(prev_ind:end) = prev_val*ones(obj.N-prev_ind+1,1);
        end
        function [t, v] = get_times(obj, tmin, tmax)
            pos = obj.timepoints>=tmin & obj.timepoints<tmax;
            t = obj.timepoints(pos);
            v = obj.vvalues(pos);
        end
    end
end