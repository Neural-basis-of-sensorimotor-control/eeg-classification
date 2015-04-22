classdef EegFigure < GuiFigure
    properties
        expr
        
        file
        eeg_signal
        eeg_time
        eeg_classification
        v_eeg
        
        tmin
        tmax
        incr
        
        ui_file
        ui_tmin
        ui_tmax
        ui_incr
        ui_tot_tmax
        
        ax_classification
        
    end

    methods
        function obj = EegFigure(expr)
            obj@GuiFigure();
            obj.expr = expr;
        end
        function populate(obj,mgr)
            mgr.newline(30)
            mgr.add(sc_ctrl('text','File'),100);
            obj.ui_file = mgr.add(sc_ctrl('popupmenu',obj.expr.values('tag'),...
                @(~,~) obj.change_file),100);
            mgr.add(sc_ctrl('text','tmin'),100);
            obj.ui_tmin = mgr.add(sc_ctrl('edit',0,...
                @(~,~) obj.change_tmin),100);
            mgr.add(sc_ctrl('text','tmax'),100);
            obj.ui_tmax = mgr.add(sc_ctrl('edit',10,...
                @(~,~) obj.change_tmax),100);
            mgr.add(sc_ctrl('text','incr'),100);
            obj.ui_incr = mgr.add(sc_ctrl('edit',10,...
                @(~,~) obj.change_incr),100);
            obj.ui_tot_tmax = mgr.add(sc_ctrl('text','tmax'),200);
            mgr.add(sc_ctrl('pushbutton','Back',...
                @(~,~) obj.backwards()),100);
            mgr.add(sc_ctrl('pushbutton','Fwd',...
                @(~,~) obj.fwd()),100);
            mgr.add(sc_ctrl('pushbutton','Update',...
                @(~,~) obj.update()),200);
        end
        
        function show(obj)
            obj.get_window();
            obj.ax_classification = axes('Parent',obj.window);
            show@GuiFigure(obj);
            obj.change_file(1);
        end
        
        function resize_window(obj)
            width = getwidth(obj.window);
            y = getheight(obj.window)-getheight(obj.panel);
            sety(obj.panel,y);
            setx(obj.panel,0);
            setwidth(obj.panel,width);

            ax_height = (y - obj.lowermargin - 2*obj.uppermargin)/2;
            setx(obj.ax,obj.leftmargin);
            sety(obj.ax,obj.lowermargin + ax_height + obj.uppermargin);
            setheight(obj.ax,ax_height);
            setwidth(obj.ax,width-obj.leftmargin-obj.rightmargin);

            setx(obj.ax_classification,obj.leftmargin);
            sety(obj.ax_classification,obj.lowermargin);
            setheight(obj.ax_classification,ax_height);
            setwidth(obj.ax_classification,width-obj.leftmargin-obj.rightmargin);
            
        end
    end
    methods (Access = 'private')
        function change_file(obj, filenbr)
            if nargin<2
                val = get(obj.ui_file,'value');
                str = get(obj.ui_file,'string');
                obj.file = obj.expr.get('tag',str{val});
            else
                obj.file = obj.expr.get(filenbr);
            end
            if ~obj.file.check_fdir()
                return
            end
            
            obj.change_tmin(0);
            obj.change_tmax(10);
            obj.change_incr(9);
            obj.eeg_signal = obj.file.signals.get('tag','EEG');
            set(obj.ui_tot_tmax,'string',obj.eeg_signal.N*obj.eeg_signal.dt);
            obj.v_eeg = obj.eeg_signal.sc_loadsignal();
            obj.eeg_time = obj.eeg_signal.t;
            if obj.file.signals.has('tag','EEG_classification')
                obj.eeg_classification = obj.file.signals.get('tag','EEG_classification');
            else
                obj.eeg_classification = ScEegClassification(obj.eeg_signal.N, ...
                    obj.eeg_signal.dt);
            end
            obj.update();
        end
        
        function change_tmin(obj, tmin)
            if nargin<2
                tmin = str2double(get(obj.ui_tmin,'string'));
            else
                set(obj.ui_tmin,'string',tmin);
            end
            obj.tmin = tmin;
            if nargin<2
                obj.update();
            end
        end
        
        function change_tmax(obj, tmax)
            if nargin<2
                tmax = str2double(get(obj.ui_tmax,'string'));
            else
                set(obj.ui_tmax,'string',tmax);
            end
            obj.tmax = tmax;
            if obj.tmin<obj.tmax
                obj.change_incr(.9*(obj.tmax-obj.tmin));
            end
            if nargin<2
                obj.update();
            end
        end
        
        function change_incr(obj, incr)
            if nargin<2
                incr = str2double(get(obj.ui_incr,'string'));
            else
                set(obj.ui_incr,'string',incr);
            end
            obj.incr = incr;
        end
        
        function backwards(obj)
            obj.change_tmin(obj.tmin-obj.incr);
            obj.change_tmax(obj.tmax-obj.incr);
            obj.update();
        end
        
        function fwd(obj)
            obj.change_tmin(obj.tmin+obj.incr);
            obj.change_tmax(obj.tmax+obj.incr);
            obj.update();
        end
        
        function update(obj)
            pos = obj.eeg_time >= obj.tmin & obj.eeg_time < obj.tmax;
            cla(obj.ax)
            plot(obj.ax,obj.eeg_time(pos), obj.v_eeg(pos));
            xlim(obj.ax, [obj.tmin obj.tmax]);
            v = obj.eeg_classification.sc_loadsignal;
            cla(obj.ax_classification)
            plot(obj.ax_classification,obj.eeg_time(pos), v(pos),'LineWidth',2);
            hold(obj.ax_classification,'on')
            set(obj.ax_classification,'ButtonDownFcn',...
                @(~,~) obj.btn_dwn_fcn());
            xlim(obj.ax_classification, [obj.tmin obj.tmax]);
            ylim(obj.ax_classification, [-12 12])
            plot(obj.ax_classification,[obj.tmin obj.tmax],-2.5*[1 1],'--',...
                [obj.tmin obj.tmax],2.5*[1 1],'--', ...
                [obj.tmin obj.tmax],7.5*[1 1],'--')
            [t,v] = obj.eeg_classification.get_times(obj.tmin, obj.tmax);
            plot(t,v,'Marker','+','LineStyle','none','LineWidth',2);
        end
        
        function btn_dwn_fcn(obj)
            cp = get(obj.ax_classification,'CurrentPoint');
            x = cp(1,1);
            y = cp(1,2);
            if      y < -2.5,   y = -5;
            elseif  y < 2.5,    y = 0;
            elseif  y < 7.5,    y = 5;
            else                y = 10;
            end
            obj.eeg_classification.set_v(x, y);
            obj.update();
        end
        

    end
end