# FigureSeer

## Running the System

1. Install JSONlab (https://www.mathworks.com/matlabcentral/fileexchange/33381-jsonlab--a-toolbox-to-encode-decode-json-files)
2. Install Caffe and its Matlab interface (http://caffe.berkeleyvision.org/installation.html). In setConf.m, edit 'conf.caffeRoot'.
3. Download the neural networks from s3://ai2-website/figureseer/neural-networks/ and save them to figureseer/data/neural-networks/
4. Compile pdffigures (included in the dependencies directory)
5. Run 'main.m'

To run on your own PDFs, simply add them to figureseer/data/pdfs and run main.

The CNN patch embedding feature used for data tracing is computantionally expensive and is disabled by default to allow CPU-only processing. If running on CPU only, you can disable it by setting "conf.usePatchCnn = false".
