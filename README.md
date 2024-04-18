# NHS-Digital-Prescribing
**Description:** The NHS-Digital-Prescribing project involves Natural Language Processing (NLP) and exploratory analysis to derive insights from Practice-level prescribing data provided by NHS Digital. The project aims to create a comprehensive dataset for analysis, combining prescribing data from NHS Digital and OpenPrescribing sources.

**Data Sources**:

NHS Digital Practice Level Prescribing - August 2019 (https://digital.nhs.uk/data-and-information/publications/statistical/practice-level-prescribing-data/august-2019); and 
OpenPrescribing (https://openprescribing.net/bnf/)

**Objective:**
The primary objective of the project was to identify the diseases and practices in the UK with the highest prescription rates and analyze the drugs with the highest prescription rates for those conditions. To achieve this, data was collected from both NHS Digital and OpenPrescribing sources. Subsequently, a unified database was created, and exploratory analysis was performed on the integrated dataset.

**Implementation:**
The project involves the following steps:

1. Reading prescribing level data from NHS Digital and OpenPrescribing sources.
2. Data processing to create a comprehensive dataset suitable for analysis.
3. Integration of data from both sources to form a unified database.
4. Implementation of NLP techniques to extract insights from the textual data.
5. Conducting exploratory analysis to uncover patterns and trends in the prescribing data.
6. Documentation and sharing of implementation details, considering the need for further explanations and improvements.


Note:

This project represents one of the initial attempts to make implementations publicly available. The provided R-file contains extensive coding and requires additional explanations. Future updates will be made to enhance documentation. Feedback and questions are welcomed to improve clarity and understanding.

**Libraries:**

    library(XML)	
    library("methods")	
    library(RCurl)	
    library(stringi)	
    library(htm2txt)	
    library(stringr)
    library(ggplot2)	
    require(tidyverse)	
    library(pivottabler)	
    library(Hmisc)	
    library(psych)	
    library(expss)

These libraries are necessary as the program utilizes NLP and visualization functionalities. Installing them may pose some difficulty. I strongly recommend running the following command before attempting to install the XML and Curl packages. (Run this command in the RStudio Terminal)

    conda install -c r r-xml=3.98_1.5
    brew install libxml2

**remark:** If you are interested in utilizing the data for your analysis without going through the procedure I implemented, you can use the following approach I have provided and access the output file. If you intend to use the file for commercial or academic purposes, we could discuss potential collaboration in that regard.

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

Acquiring domain knowledge to understand data is a fundamental phase in every data science project. To this end, after conducting research, I decided to include all BNF sections to demonstrate trends for total prescribing and more. To achieve this, our program requires NLP support. Therefore, I have developed an end-to-end code to:

    -   Connect to website and download its HTML content
    -	Process the content and extract sections, subsections, headers
    -	Create a reference table  
  
Thus, a table called SBNF was created. The key of the table is a 6-digit code corresponding to the first 6 digits of BNF codes in NHS Digital websites.

we depict the BNF components as below to how the classification system works for each BNF code. This figure provided by Seb shows the classification for Tramadol: 
![Picture1](https://user-images.githubusercontent.com/39264718/68087497-9c9dc400-fe4e-11e9-83e4-d93a7961fc5a.png)

In data processing, we faced the following challenge:
The address provided in the file were inconsistent. We could not extract the *Shire or the counties in UK. So after studding carefully about the data we took this strategy:
-	Fill the missing value of the fourth Address filed with the values of third Address field
However, even after using that strategy we had many inconsistencies. So the following strategy were devised:
-	Extract the first two character of postcode
-	For each distinct two-character, create a set involving all the names we have in different records. For example, for FY* postcode, we can see like 33 address specifically for Blackpool while the frequency of LANCASHIRE is 50. 
-	Select the name with highest frequency as the representative name of the Shire/county. For example, for FY*, the LANCASHIRE were selected.
As we were limited to use this data and we do not have enough time to bring more data in we used this strategy otherwise, the right practice is to download the whole country postcodes, process it and create a new database.
The following regions were identified:
![Picture2](https://user-images.githubusercontent.com/39264718/68087596-61e85b80-fe4f-11e9-9fa0-571501802f5e.png)

However, as we are interested to see some trends specifically for Blackpool too. I created a flag “inBK” to indicate the corresponding records to Blackpool practices.

![Picture3](https://user-images.githubusercontent.com/39264718/68087605-7c223980-fe4f-11e9-9c74-20fcae225280.png)

I used the address fields 3 and 4 to find the corresponding practices for Blackpool.

![Picture4](https://user-images.githubusercontent.com/39264718/68087631-b25fb900-fe4f-11e9-8ccb-729ab8631294.png)

What we can see is like: 

![Picture5](https://user-images.githubusercontent.com/39264718/68087640-c73c4c80-fe4f-11e9-870b-a612b5f7fd97.png)

As evident in the above figure, the program successfully identified the correct region using our strategy, and the "inBK" flag is true for the records located in Blackpool. These regions and flags are critical as they will be utilized in any further analysis.

Data preparation is the most crucial aspect of this research, consuming a significant amount of time (approximately 80%). A portion of this time was dedicated to acquiring domain knowledge, which proved to be essential for the project.

Many analyses about the data were performed part of which are in the code file; however due to the time and importance I decided to demonstrate some important figures and trends in the following parts. 
For instance, we added other fields/flags for generic and branded drugs or average price per item but I did not have time to perform analysis.

![Picture7](https://user-images.githubusercontent.com/39264718/68087656-e9ce6580-fe4f-11e9-8121-25caf0184221.png)

Please note the new measures/fields were added mostly after the final table formed. That is the fact that it is actually much easier to work on one table than many tables!

We are keen to see which the highest-level presentation in UK are. The following figure shows the top 5. Before that let’s study some figures.

![Picture8](https://user-images.githubusercontent.com/39264718/68087676-036fad00-fe50-11e9-9f04-f83e8fd3f7a9.png)

![Picture9](https://user-images.githubusercontent.com/39264718/68087678-066a9d80-fe50-11e9-9b1d-16d791f65c0c.png)

The figure for London stands out at around 50 million, significantly higher than the others (about 70% higher than the immediate highest figure before it). The reason for this disparity is evident. However, for better visualization, I will exclude it here.

In the above figure, the red dashed line represents the average ACT across all regions.

The following tables show the five highest and lowest dispensing regions. It's worth noting that statistically speaking, a city should not be compared to a county. Nevertheless, I included it here for the sake of completeness.

<img width="726" alt="Screen Shot 2019-11-03 at 3 39 22 PM" src="https://user-images.githubusercontent.com/39264718/68087717-27cb8980-fe50-11e9-9117-57e254230c11.png">

![Picture11](https://user-images.githubusercontent.com/39264718/68087747-62352680-fe50-11e9-92fa-9ecb1d8d3903.png)

The next figure demonstrates the ACT cost across Clinical Commissioning Group (CCG). Note that the Strategic Health Authority (SHA) field from April 2013 relates to the Clinical Commissioning Group (CCG).

<img width="692" alt="pic12" src="https://user-images.githubusercontent.com/39264718/68087765-7da03180-fe50-11e9-95ba-810d11359b1d.png">

As is obvious Q46,70, 68 have the highest figures among others. In the left hand side of the table the top 10 highest figures are shown.

The following figures demonstrate top 5 High-level prescribing trends across all GP practices in NHS England.

<img width="699" alt="pic13" src="https://user-images.githubusercontent.com/39264718/68087774-9e688700-fe50-11e9-97a6-6724bea52606.png">

It is quite interesting that the Cardiovascular disease that identified as the top 1 main cause of death in the previous years in Europe, now here we have the highest prescribed-level for that too. It is interesting to see the cost figure too.

![pic15](https://user-images.githubusercontent.com/39264718/68087787-bdffaf80-fe50-11e9-8a81-6e47ab6c2381.png)

Although in terms of number of items dispensed the Cardiovascular system had the highest figure, herein it stands in the third but again among top 5 highest cost! Nevertheless, the higher the number of items, the higher the cost it can be! 

It's worth noting that our results are consistent with what we can observe on openprescribing.net. They displayed national trends for the Cardiovascular System for July 2019, which amounted to about 27 million items. Examining the table above closely, in the bottom left where the top 10 figures are displayed, we observe 27.1595 million items for the cardiovascular system. This aligns with the published figure mentioned below.

<img width="632" alt="pic16" src="https://user-images.githubusercontent.com/39264718/68087811-e7204000-fe50-11e9-90de-af6614fa5f94.png">


It is also interesting to see the distribution of different medicines within Cardiovascular system. From figure below as is obvious there are some very high presentation groups. Thus it is worth to exhibit them in the next part. 

![pic17](https://user-images.githubusercontent.com/39264718/68087820-f8694c80-fe50-11e9-9eb5-28b64fc7b162.png)


The bar charts below show the distribution of top 5 medicine (Paragraphs within the main chapter (cardiovascular system).

<img width="697" alt="pic18" src="https://user-images.githubusercontent.com/39264718/68087836-1636b180-fe51-11e9-95d0-039a558e117b.png">

Comparing this figure with the previous one, we can say almost half of costs is only for one sub-chapter i.e., Oral Anticoagulants. The following pie-chart better demonstrates the proportion of these 5 compared to the rest of medicines. 

<img width="687" alt="pic19" src="https://user-images.githubusercontent.com/39264718/68087843-2e0e3580-fe51-11e9-92b2-580553c2935a.png">

Besides Cardiovascular, we can see the highest figures across all data. The following figure demonstrates the top 10 prescribed medicine across country.

<img width="693" alt="pic20" src="https://user-images.githubusercontent.com/39264718/68087853-4716e680-fe51-11e9-91e0-0566a10fb289.png">

The presentation of Oral Anticoagulants in the Cardiovascular System ranked second highest among all categories. Notably, the first two highest figures stand out significantly from the rest. However, based on the current data, we cannot draw any conclusions regarding the reasons behind this disparity. Nonetheless, given sufficient time, we could explore this further to understand how these figures are distributed among practices and regions.

Due to time constraints, we will focus solely on additional visualizations to explore the distribution of Oral Anticoagulants in practice level across the UK. We will postpone the analysis of BNF distributions across practices for the time being.

![Picture21](https://user-images.githubusercontent.com/39264718/68087862-69a8ff80-fe51-11e9-99bf-83e5d0d11186.png)

This bar chart was generated based on practice IDs rather than practice names due to the presence of similar names with different IDs. The practice names will be obtained in the subsequent stage. The practice with the highest figure is "OCTAGON MEDICAL PRACTICE".

<img width="713" alt="pic22" src="https://user-images.githubusercontent.com/39264718/68087878-9bba6180-fe51-11e9-87d1-95d5d5ef07f0.png">

![Picture23](https://user-images.githubusercontent.com/39264718/68087891-b55ba900-fe51-11e9-97b8-cda2baf1dbc0.png)

As for the graph, most of those high-level presentations we saw in national-level can be seen in this practice too. It is interesting to see if there is similar trends for main system (main classification).

![Picture24](https://user-images.githubusercontent.com/39264718/68087896-c1476b00-fe51-11e9-9a86-8a8860148df7.png)

<img width="821" alt="pic25" src="https://user-images.githubusercontent.com/39264718/68087911-ec31bf00-fe51-11e9-92cb-33c492aa9ec1.png">

The following code employs pivoting to obtain distribution of BNF across different counties in UK. There was no time to complete the execution and visualization. 
> pt <- PivotTable$new()
> pt$addData(bnf)
> pt$addColumnDataGroups("region")
> pt$addColumnDataGroups("chapterName")
> pt$addRowDataGroups("ACT")
> pt$defineCalculation(calculationName="Total", summariseExpression="sum(ACT,na.rm=TRUE)")
> pt$defineCalculation(calculationName="Average", summariseExpression="mean(ACT,na.rm=TRUE)")
> pt$defineCalculation(calculationName="SD", summariseExpression="sd(ACT,na.rm=TRUE)")
> pt$defineCalculation(calculationName="num", summariseExpression="n()")
> pt$evaluatePivot()















































