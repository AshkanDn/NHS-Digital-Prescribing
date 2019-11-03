# Ashkan Dashtban (dashtban.edu@gmail.com)
# 11/10/2019

# this file read data from NHS-Digital and openprescring, process them and create a unique comprehensive data table for 
# various kinds of analysis. I shared the output file in my google drive. Please refer to the Readme file.

################## Read chemical names and identifiers
#https://digital.nhs.uk/data-and-information/publications/statistical/practice-level-prescribing-data/july-2019
chem<- read.csv('./T201907CHEM SUBS.csv',
                stringsAsFactors = FALSE,skip = 1)
names(chem) <- c('cID','cName')
with(chem,cName<-lapply(cName, trimws ))
chem$cID <- lapply(chem$cID,str_trim)
head(chem,5)
###########################################

############################################### Bring more explanations from other websites 
####### NLP, Reguar Expression, Text procssing
#conda install -c r r-xml=3.98_1.5
# brew install libxml2
# https://stackoverflow.com/questions/37035088/unable-to-install-r-package-due-to-xml-dependency-mismatch/41604547
install.packages("XML")
library(XML)
library("methods")
install.packages("RDCOMClient", repos = "http://www.omegahat.net/R") 
install.packages("htm2txt")
library(htm2txt)
library(XML)
library(RCurl)
install.packages("tidyverse", dependencies = TRUE)
library(tidyverse)

############ Start reading
# download bnf explanations from other website
url="https://openprescribing.net/bnf/"
html <- getURL(url, followlocation = TRUE)

# parse htm, process data, extract codes and explanations
doc = htmlParse(html, asText=TRUE)
p0 <- xpathSApply(doc, "//li", xmlValue)
# extract identifiers and explanations
p<-p0[24:length(p0)]
p<- gsub("[\r\n]", "", p)
p<- str_trim(p)
bnf1<- gsub('(?<!\\d)([0-9]{1})(?!\\d)','0\\1',bnf1,perl = TRUE)
bnf2<-str_extract(p,"[a-z]+|[A-Z]+.*")
SBNF<-data.frame(bnf1,bnf2)
########################################### 


########################################### inspecting data << ignore this part>>
# read all chaptors 
SBNF[grep('^(02.02)',SBNF$bnf1,ignore.case = TRUE),]
head(SBNF)
grep('(2001)',chem$cID,value = TRUE)
grep('(2001)',chem$cID)
chem[ grep('(2001)',chem$cID),]
grep('(20.01)',SBNF$bnf1)
SBNF[,412]
SBNF$bnf2[grep('Adhesive Discs',SBNF$bnf2,ignore.case = TRUE)]
SBNF[grep('(02.02)(.*)',SBNF$bnf1,ignore.case = TRUE),]
SBNF$bnf2[grep('hlortalidone',SBNF$bnf2,ignore.case = TRUE)]
SBNF[grep('^(02.02)',SBNF$bnf1,ignore.case = TRUE),]
SBNF[grep('Chlortalidone',SBNF$bnf2,ignore.case = TRUE),]
######################################################################################


########################################### read practice data
# https://digital.nhs.uk/data-and-information/publications/statistical/practice-level-prescribing-data/july-2019
prac<- read.csv('./T201907ADDR BNFT.csv',
                stringsAsFactors = FALSE, header = FALSE,col.names = c('date','pID','pName','a1','a2','a3','a4','pcode'))


# if city is null try to fill it with previous column 
ia4<-grep('N/A',prac$a4)
paste('number of missing values in city field:',length(ia4))
prac[ia4,]$a4 <-prac[ia4,]$a3

ia44<-grep('N/A',prac$a4)
paste('number of missing values after correction:',length(ia44))
prac[ia44[1:3],]$a4 <-prac[ia44[1:3],]$a2
prac <- prac[-ia44[4:length(ia44)],]

head(prac)
pdata=prac[1,]$date
prac <- prac[,c('pID','pName','a4','pcode')]
head(prac)

#prac$a4 <- as.factor(prac$a4)
levels(as.factor(grep('leeds',prac$a4,value = TRUE,ignore.case = TRUE)))
levels(as.factor(grep('blackpool|victoria',prac$a4,value = TRUE,ignore.case = TRUE)))
bp <- grep('blackpool',prac$a4,value = FALSE,ignore.case = TRUE)
paste('practive centers in Blackpool:')
force(prac[bp,])

# extract all practices for blackpool
# we know it starts with FY
# also we know there might be a blacpook in one of the fields
bpp<- grep('^fy',prac$pcode,ignore.case = TRUE)
b1 <- bpp[unique(c(grep('blackpool',prac[bpp,]$a3,ignore.case = TRUE),grep('blackpool',prac[bpp,]$a4,ignore.case = TRUE)))]
paste('number of ares found for Blackpool:',length(b1))
prac[b1,]
######################################################################################

############################################################# Read BNF data
# https://digital.nhs.uk/data-and-information/publications/statistical/practice-level-prescribing-data/july-2019
bnf<- read.csv('./T201907PDPI BNFT.csv',
             stringsAsFactors = FALSE, header = FALSE,fill = TRUE,na.strings = 'N/A',skipNul = FALSE,
             nrows = 10)

head(bnf)
# SHA PCT PRACTICE  BNF CODE    BNF NAME ITEMS   NIC ACT COST QUANTITY PERIOD
# For data covering August 2010 to March 2013, the SHA field refers to Strategic Health Authority. 
# from April 2013 onwards, the SHA field refers to Area Team.
bnf<- read.csv('./T201907PDPI BNFT.csv',
               stringsAsFactors = FALSE, header = TRUE,fill = TRUE,na.strings = 'N/A',skipNul = FALSE,
               )

## correct link names
colnames(bnf)[3] <- 'pID'
colnames(bnf)[4] <- 'bID'
colnames(bnf)[5] <- 'bName'

# Strategic Health Authority (SHA) in which the practice resides. 
#  code of the Primary Care Trust (PCT) in which the practice resides.
# from April 2013 this field relates to the Clinical Commissioning Group (CCG)
colnames(bnf)[colnames(bnf)=='PCT'] <- 'CCG'

# https://digital.nhs.uk/data-and-information/areas-of-interest/prescribing/practice-level-prescribing-in-england-a-summary/practice-level-prescribing-glossary-of-terms
# Net ingredient cost (NIC)
# This is the cost at list price excluding VAT


# ACT
# calculate 'Actual Cost'
#The current formula is:
# - the NIC less discount
# - plus payment for consumables (previously known as Container Allowance)
# - plus payment for Containers
# - plus Out of Pocket expenses
#  This is the estimated cost to the NHS, which is lower than NIC.
colnames(bnf)[8] <- 'ACT'


# The quantity of a drug dispensed is measured in units depending on the formulation of the product,
# - number of tablets, capsules, ampoules, vials etc
# - the number of millilitres (liquid)
# - number of grammes (such as cream, gel, ointment) 

head(bnf)

# https://digital.nhs.uk/data-and-information/areas-of-interest/prescribing/practice-level-prescribing-in-england-a-summary/practice-level-prescribing-data-more-information


str(bnf)
# 'data.frame':	9508059 obs. of  10 variables:
#    $ SHA     : chr  "Q44" "Q44" "Q44" "Q44" ...
# $ CCG     : chr  "01C" "01C" "01C" "01C" ...
# $ pID     : chr  "N81002" "N81002" "N81002" "N81002" ...
# $ bID     : chr  "0101021B0AAALAL" "0101021B0AAAPAP" "0101021B0BEACAH" "0101021B0BEADAJ" ...
# $ bName   : chr  "Sod Algin/Pot Bicarb_Susp S/F" "Sod Alginate/Pot Bicarb_Tab Chble 500mg" "Gaviscon_Liq Orig Aniseed Relief" "Gaviscon Infant_Oral Pdr Sach" ...
# $ ITEMS   : int  5 2 1 5 12 2 3 2 1 1 ...
# $ NIC     : num  25.6 6.14 4.33 77.12 70.58 ...
# $ ACT.COST: num  23.86 5.73 4.04 71.75 65.76 ...
# $ QUANTITY: num  2500 120 300 240 5900 84 1500 1000 500 500 ...
# $ PERIOD  : int  201907 201907 201907 201907 201907 201907 201907 201907 201907 201907 ...


## interpretation of last 6 digits
## first 2 : ‘AA’ under product always refers to the generic for whichever drug you are interested,
## 5,6     : 'AM' generic and branded


# https://ebmdatalab.net/variation-in-out-of-pocket-expenses-in-dispensing-data/
#  we want to look at the prescribing of all opioid analgesics look at first 6 codes of 15 code
#  or look at all generics in a paragraph we can search under product for ‘AA’. (first 2 chars of 6 last code)
# ? what is the total revenue and 5 top spending
# ? how spending differs across various practices
# ? The most expensive product across the whole NHS for OOPE is Cinacalcet Tablets 30mg?
# ? The most expensive single expense
# ? The most expensive product classes overall are Vitamin D (£67,000 per month);


############################################################# 
############################################################# 
## some statisical summeris
################################################################################ 
library(pastecs)
stat.desc(s$ACT)
library(Hmisc)
describe(s$ACT) 

library(Hmisc)
describe(bnf) 
# 
# > describe(bnf) 
# bnf 
# 
# 10  Variables      9508059  Observations
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#    SHA 
# n  missing distinct 
# 9508059        0       27 
# 
# lowest : Q44 Q45 Q46 Q47 Q48, highest: Q66 Q67 Q68 Q69 Q70
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#    CCG 
# n  missing distinct 
# 9508059        0      396 
# 
# lowest : 00C 00D 00J 00K 00L, highest: RYJ RYK RYW RYX RYY
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#    pID 
# n  missing distinct 
# 9508059        0     9404 
# 
# lowest : A81001 A81002 A81004 A81005 A81006, highest: Y06493 Y06494 Y06498 Y06502 Y06504
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#    bID 
# n  missing distinct 
# 9508059        0    22822 
# 
# lowest : 0101010C0AAAAAA 0101010C0BBAAAA 0101010F0AAAUAU 0101010F0BCAAAU 0101010G0AAABAB, highest: 23965909621     23965909622     23965909624     23965909625     23965909627    
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#    bName 
# n  missing distinct 
# 9508059        0    22769 
# 
# lowest : 1 Primary 10ml Spy Wound Dress Protease Matrix 1 Primary 17ml Spy Wound Dress Protease Matrix 365 Community Woundcare Pack Ster Dress Pack   365 Film 10cm x 12cm VP Adh Film Dress         365 Film 10cm x 15cm VP Adh Film Dress        
# highest: Zyprexa_Velotab 20mg                           Zyprexa_Velotab 5mg                            Zytram SR_Tab 100mg                            Zytram SR_Tab 150mg                            Zytram SR_Tab 200mg                           
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#    ITEMS 
# n  missing distinct     Info     Mean      Gmd      .05      .10      .25      .50      .75      .90      .95 
# 9508059        0        1366    0.935     9.638    14.59      1        1        1        2        6       19       39 
# 
# lowest :    1    2    3    4    5, highest: 3878 3983 4166 4492 4540
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#    NIC 
# n  missing distinct     Info     Mean      Gmd      .05      .10      .25      .50      .75      .90      .95 
# 9508059        0      100478     1        77.06    110.3     2.48     3.88     8.81    24.48    67.36   172.74   294.66 
# 
# lowest :     0.00     0.01     0.02     0.03     0.04, highest: 25684.32 29470.00 29810.76 29918.60 36193.44
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#    ACT.COST 
# n  missing distinct     Info       Mean      Gmd      .05      .10      .25      .50      .75      .90      .95 
# 9508059        0       127378        1      71.99    102.9     2.35     3.65     8.30    23.02    63.13   161.39   275.41 
# 
# lowest :     0.00     0.01     0.02     0.03     0.04, highest: 23884.99 27396.97 27811.36 28028.54 34425.48
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#    QUANTITY 
# n           missing  distinct     Info     Mean      Gmd      .05      .10      .25      .50      .75      .90      .95 
# 9508059        0      28870       0.999      748     1283        2        5       28       90      336     1200     2800 
# 
# lowest :       0.00       0.47       0.70       0.94       1.00, highest: 1335130.00 1767908.00 2028915.00 2532580.00 2820982.00
# ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#    PERIOD 
# n  missing distinct     Info     Mean      Gmd 
# 9508059        0        1        0   201907        0 
# 
# Value       201907
# Frequency  9508059
# Proportion       
#### from this simple analysis : no missing values, quantity is unreliable (three types we have!), 
## highest costs are incredibly high : 1335130.00 1767908.00 2028915.00 2532580.00 2820982.00


library(psych)
describe(bnf)
# vars       n      mean      sd    min        max      range   se
# SHA         1 9508059       NaN      NA    Inf       -Inf       -Inf   NA
# CCG         2 9508059       NaN      NA    Inf       -Inf       -Inf   NA
# pID         3 9508059       NaN      NA    Inf       -Inf       -Inf   NA
# bID         4 9508059       NaN      NA    Inf       -Inf       -Inf   NA
# bName       5 9508059       NaN      NA    Inf       -Inf       -Inf   NA
# ITEMS       6 9508059      9.64   32.45      1    4540.00    4539.00 0.01
# NIC         7 9508059     77.06  224.62      0   36193.44   36193.44 0.07
# ACT         8 9508059     71.99  209.25      0   34425.48   34425.48 0.07
# QUANTITY    9 9508059    748.01 4771.22      0 2820982.00 2820982.00 1.55
# PERIOD     10 9508059 201907.00    0.00 201907  201907.00       0.00 0.00


library(pastecs)
stat.desc(bnf[,6:9]) 
#                 ITEMS          NIC          ACT     QUANTITY
# nbr.val      9.508059e+06 9.508059e+06 9.508059e+06 9.508059e+06
# nbr.null     0.000000e+00 1.940000e+02 1.920000e+02 1.000000e+00
# nbr.na       0.000000e+00 0.000000e+00 0.000000e+00 0.000000e+00
# min          1.000000e+00 0.000000e+00 0.000000e+00 0.000000e+00
# max          4.540000e+03 3.619344e+04 3.442548e+04 2.820982e+06
# range        4.539000e+03 3.619344e+04 3.442548e+04 2.820982e+06
# sum          9.163966e+07 7.326441e+08 6.844656e+08 7.112116e+09
# median       2.000000e+00 2.448000e+01 2.302000e+01 9.000000e+01
# mean         9.638104e+00 7.705506e+01 7.198794e+01 7.480092e+02
# SE.mean      1.052423e-02 7.284499e-02 6.786120e-02 1.547333e+00
# CI.mean.0.95 2.062712e-02 1.427736e-01 1.330055e-01 3.032717e+00
# var          1.053107e+03 5.045350e+04 4.378596e+04 2.276456e+07
# std.dev      3.245161e+01 2.246186e+02 2.092510e+02 4.771222e+03
# coef.var     3.367012e+00 2.915040e+00 2.906750e+00 6.378560e+00

################################################################################  add new measures/fields
# add new complementary fields
bnf['chID'] <- substr(bnf$bID,1,9)
# add generic label
bnf['isGeneric'] <- toupper(substr(bnf$bID,10,11)) == 'AA'
# add generic&branded
bnf['isGB'] <- toupper(substr(bnf$bID,14,15)) == 'AM'
head(bnf)
# add actual cost per item
bnf['ACTperItem'] <- round(bnf$ACT / bnf$ITEMS,digits = 3)

################################################################################  create a region field (*shires)
### the adress is not consistent and we need aditional data, so we try to use this trick to extract real regions based on postcode (the most trustworthy field):
# we utilize the first 2 charater of postcode as 'specific region' then
# we use the mode to assing the most probable name to that region
# to do the above steps we need to link bnf to practice data

i1 <- grep('B',prac$pcode,ignore.case = TRUE)
i2 <- levels(as.factor(prac[i1,]$a4))

# a<-names(which.max(summary(as.factor(prac[grep('^B1',prac$pcode),]$a4)))[1])
# lapply(prac,)

group <- as.factor(substr(prac$pcode,1,2))
t<- by(prac$a4, group, function (x) names(which.max(summary(as.factor(x)))[1]))
force(length(t))

prac$region <- substr(prac$pcode,1,2)
prac$region<-lapply(prac$region, function (x) t[names(t)==x][[1]]);

prac$region <- as.factor(as.character(prac$region))
force(str(prac$region))
force(sort(unique(prac$region),decreasing = TRUE))

force(length(unique(prac$region)))

force(length(t))


######################################################### link data together #### create final table
### let's link prac to bnf
head(bnf)
head(prac)
head(chem)
head(SBNF)

bnf <- merge(bnf,prac[,c('pID','region','pName')],by = 'pID',all.x = TRUE)

## let's add chemical name and then chapters
bnf <- merge(bnf,chem,by.x = "chID",by.y = "cID",all.x = TRUE)
head(bnf,5)

### lest add chapter information 
# we need to groupby data 
library(stringr)
chapterIdx <- str_length(SBNF$bnf1) == 2
df2<-SBNF[chapterIdx,]

names(df2)[2] <- 'chapterName'
df2$chapterName <- as.character(df2$chapterName)
bnf['chapterId'] <- as.factor(substr(bnf$bID,1,2))


bnf <- merge(bnf,df2,by.x = "chapterId" ,by.y = "bnf1",all.x = TRUE,)

# add paragraph
parIdx <- str_length(SBNF$bnf1) == 8
df2<-SBNF[parIdx,]
df2$parID <- str_replace_all(df2$bnf1,'(\\.)',"")
colnames(df2)[2] <- 'parName'
head(df2,5)

bnf$parID  <- as.factor(substr(bnf$bID,1,6))
bnf <- merge(bnf,df2[,c('parName','parID')],by = "parID",all.x = TRUE)
head(bnf,5)

### add flag for Blackpool
bp <- unique(c(grep('blackpool',prac$a4,value = FALSE,ignore.case = TRUE),
               grep('blackpool',prac$a3,value = FALSE,ignore.case = TRUE)))
paste('practive centers in Blackpool:', length(bp))
force(prac[bp,])


prac$inBK <- FALSE
prac$inBK[bp] <- TRUE
prac <- prac

bnf <- merge(bnf,prac[,c('pID','inBK')],by = 'pID',all.x = TRUE)
head(bnf)
##############################################################################################################

######################################
## remove missing valuses for region
bnf<-bnf[!is.na(bnf$region),] 

################################################ visualization

# set blackpool identifier
## select Blackpool one
bId <- which(bnf$inBK,arr.ind = TRUE)

s <- tapply(bnf$ACT, bnf$region, sum)
s <- data.frame(region <- dimnames(s),ACT=as.vector(s),stringsAsFactors = FALSE)
names(s)[1] <- 'region'
s <- rbind(s,c('BLACKPOOL',sum(bnf[bId,]$ACT,na.rm = TRUE)))

# convert to million
s$ACT <- round(as.numeric(s$ACT)/1000000,2)
s$region <- as.character(s$region)

dev.off()
g<-ggplot(data=s, aes(x=1:length(s$region), y=ACT, group=1)) +
   geom_line(color="blue",size=1)
g
g+ geom_hline(yintercept=mean(s$ACT),linetype="dashed", color = "red")
# exclude lonon
s <- s[-30,]
g<-ggplot(data=s, aes(x=1:length(s$region), y=ACT, group=1)) +
   geom_line(color="blue",size=1)
g
g+ geom_hline(yintercept=mean(s$ACT),linetype="dashed", color = "red")

## same analysis for Clinical Commissioning Group (CCG)
s <- tapply(bnf$ACT, bnf$SHA, sum)
s <- data.frame(region <- dimnames(s),ACT=as.vector(s),stringsAsFactors = FALSE)
names(s)[1] <- 'CCG'

s$ACT <- round(as.numeric(s$ACT)/1000000,2)
s$CCG <- as.character(s$CCG)

dev.off()
ggplot(data=s, aes(x=CCG, y=ACT)) +
   geom_bar(stat="identity",fill='maroon') +
   coord_flip()

s[order(-s$ACT),][1:10,]

## analysis over BNF sections
# the 5 top High-level presentations figures 
s <- tapply(bnf$ITEMS,bnf$chapterName,sum)
s <- data.frame(chapter <- dimnames(s),ACT=as.vector(s),stringsAsFactors = FALSE)
names(s)[1] <- 'BNFChapter'
names(s)[2] <- 'ITEM'
s$ITEM<- round(as.numeric(s$ITEM)/1000000,4)

s <- s[order(-s$ITEM),][1:5,]

dev.off()
ggplot(data=s, aes(x=BNFChapter, y=ITEM)) +
   geom_bar(stat="identity",fill='dark green') 


# for cost
s <- tapply(bnf$ACT,bnf$chapterName,sum)
s <- data.frame(chapter <- dimnames(s),ACT=as.vector(s),stringsAsFactors = FALSE)
names(s)[1] <- 'BNFChapter'
names(s)[2] <- 'Cost'
s$Cost<- round(as.numeric(s$Cost)/1000000,4)

s <- s[order(-s$Cost),][1:5,]

dev.off()
ggplot(data=s, aes(x=BNFChapter, y=Cost)) +
   geom_bar(stat="identity",fill='royalblue') +
   coord_flip() +
   scale_x_discrete(limits=s$BNFChapter) 

##### cross reference analysis
# distribution of paragraphs in highest presentations
idx<-which(bnf$chapterName=="Cardiovascular System")
s <- tapply(bnf[idx,]$ACT,bnf[idx,]$parName,sum)
s <- data.frame(paragraph <- dimnames(s),ACT=as.vector(s),stringsAsFactors = FALSE)
names(s)[1] <- 'Paragraph'
names(s)[2] <- 'Cost'
s$Cost<- round(as.numeric(s$Cost)/1000000,2)

s <- s[order(-s$Cost),][1:5,]
dev.off()
ggplot(data=s, aes(x=Paragraph, y=Cost)) +
   geom_bar(stat="identity",fill='#cc0099') +
   scale_x_discrete(limits=s$Paragraph) +
   coord_flip()

# a pie chart to compare these paragraps with the rest
theRest <- round(sum(bnf[idx,]$ACT)/1000000- sum(s$Cost),2)
s[6,]=c('theRest',theRest)
  
dev.off()
# barchart
ggplot(data=s, aes(x=Paragraph, y=Cost,fill = Paragraph)) +
   geom_bar(stat="identity",fill='#cc0099') +
   scale_x_discrete(limits=s$Paragraph)

# the analsis for all paragraphs
s <- tapply(bnf$ACT,bnf$parName,sum)
s <- data.frame(paragraph <- dimnames(s),ACT=as.vector(s),stringsAsFactors = FALSE)
names(s)[1] <- 'Paragraph'
names(s)[2] <- 'Cost'
s$Cost<- round(as.numeric(s$Cost)/1000000,2)

s <- s[order(-s$Cost),][1:10,]
dev.off()


ggplot(s, aes(x =Paragraph , y = Cost, fill = Paragraph)) +
   geom_bar(width = 1, stat = "identity", color = "white") +
   scale_x_discrete(limits=s$Paragraph)+
   geom_text(aes(y = Cost, label = Cost), color = "black")+
   coord_flip()

###################
# the analsis for all practices
s <- tapply(bnf$ACT,bnf$pID,sum)
s <- data.frame(practice <- dimnames(s),ACT=as.vector(s),stringsAsFactors = FALSE)


names(s)[1] <- 'practice'
names(s)[2] <- 'Cost'
s$Cost<- round(as.numeric(s$Cost)/1000000,2)

s <- s[order(-s$Cost),][1:10,]
dev.off()

ggplot(s, aes(x =practice , y = Cost, fill = practice)) +
   geom_bar(width = 1, stat = "identity", color = "white") +
   scale_x_discrete(limits=s$practice)+
   geom_text(aes(y = Cost, label = Cost), color = "black")+
   coord_flip()


## distribution of prescription for the highest practice 'D81022'
idx<-which(bnf$pID=="D81022")
s <- tapply(bnf[idx,]$ACT,bnf[idx,]$parName,sum)
s <- data.frame(paragraph <- dimnames(s),ACT=as.vector(s),stringsAsFactors = FALSE)
names(s)[1] <- 'Paragraph'
names(s)[2] <- 'Cost'

s$Cost<- round(as.numeric(s$Cost)/1000,2)
s <- s[order(-s$Cost),][1:10,]
dev.off()

ggplot(s, aes(x =Paragraph , y = Cost, fill = Paragraph)) +
   geom_bar(width = 1, stat = "identity", color = "white") +
   scale_x_discrete(limits=s$Paragraph)+
   geom_text(aes(y = Cost, label = Cost), color = "black")+
   coord_flip()


## distribution of main chaptor for the highest practice 'D81022'
idx<-which(bnf$pID=="D81022")
s <- tapply(bnf[idx,]$ACT,bnf[idx,]$chapterName,sum)
s <- data.frame(chapter <- dimnames(s),ACT=as.vector(s),stringsAsFactors = FALSE)
names(s)[1] <- 'chapter'
names(s)[2] <- 'Cost'

s$Cost<- round(as.numeric(s$Cost)/1000,2)
s <- s[order(-s$Cost),][1:10,]
dev.off()

ggplot(s, aes(x =chapter , y = Cost, fill = chapter)) +
   geom_bar(width = 1, stat = "identity", color = "white") +
   scale_x_discrete(limits=s$chapter)+
   geom_text(aes(y = Cost, label = Cost), color = "black")+
   coord_flip()


s <- tapply(bnf$ACT,bnf$parName,sum)
s <- data.frame(paragraph <- dimnames(s),ACT=as.vector(s),stringsAsFactors = FALSE)
names(s)[1] <- 'Paragraph'
names(s)[2] <- 'Cost'
s$Cost<- round(as.numeric(s$Cost)/1000000,2)

s <- s[order(-s$Cost),][1:5,]
dev.off()
ggplot(data=s, aes(x=Paragraph, y=Cost)) +
   geom_bar(stat="identity",fill="#9999ff")+
   scale_x_discrete(limits=s$Paragraph) 


# draw only for 5 lowest
dev.off
s0<-s[order(s$ACT),][1:5,]
g<- ggplot(data=s0, aes(x=region, y=ACT, group=1)) +
   geom_line()+
   geom_text(aes(label=region), vjust=1.6, color="red", size=2.5)+
   geom_point()
g+ ggtitle('5 lowest dispensing')


# draw for lowest 5
dev.off
g <- ggplot(s[1:5,], aes(region))
      g + geom_bar(aes(weight = ACT))
      

# the 5 top High-level presentations figures 
s1 <- tapply(bnf$ACT,bnf$chapterName,sum)
s1 <- data.frame(chapter <- dimnames(s1),ACT=as.vector(s1),stringsAsFactors = FALSE)
      
names(s1)[1] <- 'region'
s1$ACT <- as.numeric(s1$ACT)
s1$region <- as.character(s1$region)         
    
s1$pragraph <- as.factor(s1$pragraph)
s2<-s1[order(-s1$ACT),][1:5,]

g <- ggplot(s2, aes(pragraph))
g + geom_bar(aes(weight = ACT)) + ggtitle("Top 5 drugs")

dev.off()
g <- ggplot(data.frame(x,y), aes(x))
g + geom_bar(aes(weight = y)) + ggtitle("Top 5 drugs")


    
# the 5 top High-level presentations in paragraph level
s1 <- tapply(bnf$ACT,bnf$parName,sum)
s1 <- data.frame(pragraph <- dimnames(s1),ACT=as.vector(s1),stringsAsFactors = FALSE)
names(s1)[1] <- 'pragraph'
s1 <- s1[!is.na(s1[,2]),]

s1$pragraph <- as.factor(s1$pragraph)
s2<-s1[order(-s1$ACT),][1:5,]

g <- ggplot(s2, aes(pragraph))
g + geom_bar(aes(weight = ACT)) + ggtitle("Top 5 drugs")

dev.off()
g <- ggplot(data.frame(x,y), aes(x))
g + geom_bar(aes(weight = y)) + ggtitle("Top 5 drugs")
########################################################################################


########################################################################################
############################################### Pivoting ###############################
########################################################################################
#https://stackoverflow.com/questions/6667091/pivot-table-like-output-in-r?lq=1
library(expss)
(bnf$chapterName <- as.factor(bnf$chapterName.x))
bnf %>% 
   # 'tab_cells' - variables on which statistics will be calculated
   # "|" is needed to suppress 'growth' in row labels
   tab_cells("|" = ACT) %>%  
   # 'tab_cols' - variables for columns. Can be ommited
   tab_cols(total(label = "")) %>% 
   # 'tab_rows' - variables for rows.
   tab_rows(region %nest% list(chapterName, "(All)"), "|" = "(All)") %>% 
   # 'method = list' is needed for statistics labels in column
   tab_stat_fun("sumTotal"=sum,
                "Average Growth" = mean, 
                "Std Dev" = sd, 
                "# of scholars" = length, 
                method = list) %>% 
   # finalize table
   tab_pivot() %>% tbpv

install.packages("pivottabler")
library(pivottabler)
qq<- qpvt(bnf, c("region", "chapterName"), NULL, 
     c("Sum"="sum(ACT,na.rm=TRUE)","Average"="mean(ACT,na.rm=TRUE)", 
       "Std_Dev"="sd(ACT,na.rm=TRUE)",
       "nPrescrib"="n()"),
         formats=list("%.1f", "%.1f", "%.1f","%.0f"))
########################################################################################

                
                
                
 
