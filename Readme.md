# FigureSeer: Parsing Result-Figures in Research Papers

### Introduction

FigureSeer is a system for parsing result-figures in research papers. It automatically localizes figures, classifies them, and analyses their content.

### Citing FigureSeer

If you find FigureSeer useful in your research, please consider citing:

    @inproceedings{siegelnECCV16figureseer,
        Author = {Noah Siegel and Zachary Horvitz and Roie Levin and Santosh Divvala and Ali Farhadi},
        Title = {FigureSeer: Parsing Result-Figures in Research Papers},
        Booktitle = {European Conference on Computer Vision ({ECCV})},
        Year = {2016}
    }
    
### Requirements: Software

1. Caffe and its Matlab interface (http://caffe.berkeleyvision.org/installation.html)
2. JSONlab (https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files)

### Requirements: Hardware

The default configuration for FigureSeer runs entirely on CPU. The CNN patch embedding feature used for data tracing is computantionally expensive and is disabled by default. If running on a GPU, you can enable it by setting "conf.useGPU = true" and "conf.usePatchCnn = true" in setConf.m.

### Installation

1. Download the neural networks from s3://ai2-website/figureseer/neural-networks/ and save them to figureseer/data/neural-networks/
2. Compile pdffigures (included in the dependencies directory)
3. In setConf.m, edit 'conf.caffeRoot' to point to your Caffe installation.
4. Run 'main.m'

To run on your own PDFs, simply add them to figureseer/data/pdfs and run main.

### Data

Data used for training models is available at the project webpage: http://allenai.org/plato/figureseer/.
