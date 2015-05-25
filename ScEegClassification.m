classdef ScEegClassification < handle
    methods (Static)
        function str = tag()
            str = 'EEG_classification';
        end
    end
    
    properties
        N
        dt
        timepoints
        vvalues
        filter
    end
    properties (Dependent)
        t
    end
    methods
        function obj = ScEegClassification(N, dt)
            obj.filter = ScSignalFilter(obj);
            obj.vvalues = [];
            obj.timepoints = [];
            obj.dt = dt;
            obj.N = N;
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
                prev_ind = max(1,ind+1);
                prev_val = obj.vvalues(k);
            end
            v(prev_ind:end) = prev_val*ones(obj.N-prev_ind+1,1);
        end
        function [t, v] = get_times(obj, tmin, tmax)
            pos = obj.timepoints>=tmin & obj.timepoints<tmax;
            t = obj.timepoints(pos);
            v = obj.vvalues(pos);
        end
        function sc_clear(~)
        end
        
        function sc_loadtimes(~)
        end
        function trg = triggers(~)
            trg = ScCellList();
        end
        function rmwfs = get_rmwfs(~,~,~)
            rmwfs = ScList();
        end
        function val = get.t(obj)
            val = ( 0:(obj.N-1) )*obj.dt;
        end
    end
end