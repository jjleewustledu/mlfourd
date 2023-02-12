classdef PhysioTool < handle
    %% Implementations of QC from J. Power, et al. Sources and implications of whole-brain fMRI signals in humans.
    %  Supports HCP data formats only.
    %  [Neuroimage 146 609-625 2017/2/1](https://doi.org/10.1016/j.neuroimage.2016.09.038)
    %  
    %  Created 07-Oct-2022 21:38:41 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.13.0.2049777 (R2022b) for MACI64.  Copyright 2022 John J. Lee.
    
    properties 
        bold
        frame_displacement
        ifv_dmrecess
        physio
        physio_sampling_rate
        tr
        wmparc
    end

    properties (Dependent)
        times_bold
        times_physio
    end

    methods

        %% GET

        function g = get.times_bold(this)
            Nt_ = size(this.bold, 4);
            g = this.tr*(1:Nt_)';
        end
        function g = get.times_physio(this)
            g = (0:length(this.physio)-1)'/this.physio_sampling_rate;
        end

        %%

        function bb = greyscale_heatmap(this)
        end
        function fd_obj = fd(this)
            fd_obj = this.frame_displacement;
        end
        function gs = global_signal(this)
        end
        function hr_vec = heart_rate(this)
            data_ = this.physio(:,3);
            Nt_ = size(this.bold, 4);
            time_bold_ = this.tr*(1:Nt_)';
            time_phys_ = (0:length(data_)-1)'/this.physio_sampling_rate;

            hr_vec = zeros(size(time_bold_));            
            for i = 1:length(hr_vec)
                [~,phys_start] = min(abs(time_phys_ - (time_bold_(i) - 3)));
                [~,phys_end] = min(abs(time_phys_ - (time_bold_(i) + 3)));

                [pks,locs] = findpeaks(data_(phys_start:phys_end), ...
                    'minpeakdistance', round(this.physio_sampling_rate/(180/60)));
                  %,'minpeakwidth',400/(1/(200/60))); % max heart rate = 180 bpm; at 400 Hz, minimum of 100 samples apart
                locs = locs(pks > prctile(data_(phys_start:phys_end), 60));
                tau = diff(locs)/this.physio_sampling_rate; % sec
                hr_vec(i) = mean(60./tau, 'omitnan'); % beats/min
            end
        end
        function hrv_vec = hrv(this)
            data_ = this.physio(:,3);
            Nt_ = size(this.bold, 4);
            time_bold_ = this.tr*(1:Nt_)';
            time_phys_ = (0:length(data_)-1)'/this.physio_sampling_rate;

            hrv_vec = zeros(size(time_bold_));            
            for i = 1:length(hrv_vec)
                [~,phys_start] = min(abs(time_phys_ - (time_bold_(i) - 3)));
                [~,phys_end] = min(abs(time_phys_ - (time_bold_(i) + 3)));

                [pks,locs] = findpeaks(data_(phys_start:phys_end), ...
                    'minpeakdistance', round(this.physio_sampling_rate/(180/60)));
                  %,'minpeakwidth',400/(1/(200/60))); % max heart rate = 180 bpm; at 400 Hz, minimum of 100 samples apart
                locs = locs(pks > prctile(data_(phys_start:phys_end), 60));
                tau = diff(locs)/this.physio_sampling_rate; % sec
                hrv_vec(i) = std(60./tau, 'omitnan'); % beats/min
            end
        end
        function ifv_obj = ifv(this)
            %  Returns:
            %      ifv_obj mlphysio.IFV
        end
        function pa_vec = peak_amplitude(this)
            data_ = this.physio(:,3);
            Nt_ = size(this.bold, 4);
            time_bold_ = this.tr*(1:Nt_)';
            time_phys_ = (0:length(data_)-1)'/this.physio_sampling_rate;

            pa_vec = zeros(size(time_bold_));            
            for i = 1:length(pa_vec)
                try
                    [~,phys_start] = min(abs(time_phys_ - (time_bold_(i) - 3)));
                    [~,phys_end] = min(abs(time_phys_ - (time_bold_(i) + 3)));
    
                    pks = findpeaks(data_(phys_start:phys_end), ...
                        'minpeakdistance', round(this.physio_sampling_rate/(180/60)));
                      %,'minpeakwidth',400/(1/(200/60))); % max heart rate = 180 bpm; at 400 Hz, minimum of 100 samples apart
                    pa_vec(i) = mean(pks, 'omitnan');
                catch
                end
            end
        end
        function po_vec = pulse_oximeter(this)
            data_ = this.physio(:,3);
            Nt_ = size(this.bold, 4);
            time_bold_ = this.tr*(1:Nt_)';
            time_phys_ = (0:length(data_)-1)'/this.physio_sampling_rate;

            po_vec = zeros(size(time_bold_));            
            for i = 1:length(po_vec)
                try
                    [~,phys_start] = min(abs(time_phys_ - (time_bold_(i) - 3)));
                    [~,phys_end] = min(abs(time_phys_ - (time_bold_(i) + 3)));
    
                    po_vec(i) = mean(data_(phys_start:phys_end), 'omitnan');
                catch
                end
            end
        end
        function rb_vec = resp_belt(this)
            data_ = this.physio(:,2);
            Nt_ = size(this.bold, 4);
            time_bold_ = this.tr*(1:Nt_)';
            time_phys_ = (0:length(data_)-1)'/this.physio_sampling_rate;

            rb_vec = zeros(size(time_bold_));            
            for i = 1:length(rb_vec)
                [~,phys_start] = min(abs(time_phys_ - (time_bold_(i) - 3)));
                [~,phys_end] = min(abs(time_phys_ - (time_bold_(i) + 3)));
                rb_vec(i) = mean(data_(phys_start:phys_end));
            end
        end
        function rv_vec = rv(this)
            data_ = this.physio(:,2);
            Nt_ = size(this.bold, 4);
            time_bold_ = this.tr*(1:Nt_)';
            time_phys_ = (0:length(data_)-1)'/this.physio_sampling_rate;

            rv_vec = zeros(size(time_bold_));            
            for i = 1:length(rv_vec)
                [~,phys_start] = min(abs(time_phys_ - (time_bold_(i) - 3)));
                [~,phys_end] = min(abs(time_phys_ - (time_bold_(i) + 3)));
                rv_vec(i) = std(data_(phys_start:phys_end));
            end
        end

        function this = PhysioTool(bold, wmparc, nameValueArgs)
            %import mlfourd.ImagingContext2
            arguments (Input)
                bold {mustBeNonempty}
                wmparc {mustBeNonempty}
                nameValueArgs.frame_displacement {mustBeFile}
                nameValueArgs.ifv_dmrecess {mustBeNumeric} = 22 % dorsalmedial recess of 4th ventricle, include smaller coords
                nameValueArgs.physio {mustBeFile}
                nameValueArgs.physio_sampling_rate {mustBeNumeric} = 400
                nameValueArgs.tr {mustBeNumeric} = 0.72
            end
            this.bold = mlfourd.ImagingContext2(bold);
            this.wmparc = mlfourd.ImagingContext2(wmparc);
            if isfield(nameValueArgs, "frame_displacement")
                this.frame_displacement = importdata(nameValueArgs.frame_displacement);
            end
            if isfield(nameValueArgs, "ifv_dmrecess")
                this.ifv_dmrecess = nameValueArgs.ifv_dmrecess;
            end
            if isfield(nameValueArgs, "physio")
                this.physio = importdata(nameValueArgs.physio);
            end
            if isfield(nameValueArgs, "physio_sampling_rate")
                this.physio_sampling_rate = nameValueArgs.physio_sampling_rate;
            end
            if isfield(nameValueArgs, "tr")
                this.tr = nameValueArgs.tr;
            end
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
