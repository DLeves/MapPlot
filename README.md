# MapPlot

## Magyar
A KSH TIMEA felületének reprodukciója R Shiny-ban a szakdolgozatom adattáblájával.

Az adatok többségében Balázs által KSH TIMEA-ról scrapelt adattábla alapján vannak, járások neve szerint sorbarendezve.
Ahhoz, hogy más változók neveit lehessen mutatni a fent említett dataset-ből ahhoz a `ui`-ban kell kicserélni a `SelectInput` függvény `choices` paraméterében a következő módon: ```c("Az appban megjelenő változónév" = "A dataframe oszlopának neve",...)```

## English
An imitation of KSH's TIMEA interactive map in R Shiny with the dataset of my thesis

Most of the data are based on a data table scraped by Balázs from KSH TIMEA, sorted by district name.
In order to show other variable names from the dataset mentioned above, you need to replace in `ui` in the `choices` parameter of the `SelectInput` function with ```c("Variable name displayed in the app" = "Name of the column of the dataframe",...)```
