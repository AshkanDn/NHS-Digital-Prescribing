# NHS-Digital-Prescribing
NLP + Exploratory Analysis for deriving insights from Practice level prescribing - NHS Digital
After four years of working in data science field I decided to share some of my implementation and techniques publicaly. It is a large coding file and need much more explanaiton. whenver I have time I will come and complete it. However, do not hesitate to ask your questions.

The way the analysis has been done detailed through the following steps:
    Domain knowledge {NHS term glossary, Article}
    Data preparation 
    NLP,
    Data processing 
    Curation, inspecting for missing/extreme values
    Adding measures
    Linking data and produce one final unit of data for analysis
    Studding about data and visualization

In this report, I included the implementation beside some of the graphs and bar charts. However, some explanations are necessary.
For running this code, the following libraries should be installed.

library(XML)	library("methods")	library(RCurl)	library(stringi)	library(htm2txt)	library(stringr)
library(ggplot2)	require(tidyverse)	library(pivottabler)	library(Hmisc)	library(psych)	brary(expss)

These libraries are required because the written programme use NLP and visualizations. There might be difficulty in installing them. I strongly suggest to run the following command before start installing XML and Curl packages. (Run in the Terminal of RStudio)

conda install -c r r-xml=3.98_1.5
brew install libxml2

remark: if you are interested to use data for your analysis without going through the procedure I had gone, use the following approach I have provided and shared the output file. If you want to use the file for commercial or academic purposes we could have collaboration in that regard.

You can use the data directly using the following command:
 
load(file='dNHS.RData')

This file is shared in my google.drive at the following address (it is 300M):
https://drive.google.com/open?id=1BVbKlgeKAy4VkmPrAglEqRGvdWwlp3Wp
This file contains 4 tables called: bnf, chem, prac and SBNF. 
  Chem: chemical names
  Prac: practice data
  Bnf: big bnf file
  SBNF:  a complementary file we will describe later
I added some measures to the data like, “is generic”, “is generic and branded” that were important for further analysis. However, I did not have time to use them for any analysis in this report.

Acquiring domain knowledge to understand data is fundamental phase in every data science projects. To this end, after some research, I came to this idea of including All BNF sections so as to demonstrate trends for total prescribing and etc. To do so, we need NLP support in our programme. Therefore, I wrote an end-to-end code to:
  -	Connect to website and download its HTML content
  -	Process the content and extract sections, subsections, headers
  -	Create a reference table  
Thus, a table called SBNF was created. The key of the table is a 6-digit code corresponding to the first 6 digits of BNF codes in NHS Digital websites.




