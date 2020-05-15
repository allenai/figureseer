# FigureSeer: Parsing Result-Figures in Research Papers

NB: FigureSeer is no longer being actively maintained. Code is provided for informational purposes only. If you're interested in taking over maintenance, please contact siegeln@uw.edu.

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

### Installation

1. Clone the repo with `git clone --recursive https://github.com/allenai/figureseer`
2. Download model weights from [https://drive.google.com/corp/drive/folders/18oQ6LZbxVTH7qgEY9tj7YdstdRpr0HV_](https://drive.google.com/corp/drive/folders/18oQ6LZbxVTH7qgEY9tj7YdstdRpr0HV_) and save them to `data/models/neural-networks/`.
3. Compile pdffigures (included in the dependencies directory)
4. In setConf.m, edit 'conf.caffeRoot' to point to your Caffe installation.
5. Run 'main.m'

To run on your own PDFs, simply add them to figureseer/data/pdfs and run main.

### Data

Data used for training models is available at the project webpage: http://allenai.org/plato/figureseer/.

### License

FigureSeer is released under the GPLv2 License.
