# IMDb Top 250 Movies scraping #

In this project, R language is used to scrap data from IMDb Top 250 Movies, crate a csv file and plot some of the data collected.

To scrap data (like movie titles, ratings, duration etc) we use the **library "rvest"** and the **library "ggplot2"** for the plots.  

$Note_1$: *If you don't use any API key, to have full access to data just download the html of the page you want to scrap data and add the path/ to/ your/ file in the code.*

$Note_2$: *If the html of the page changed, just update accordingly in the code the parts of the html you want to scrap data from. Also update some parts for the missing data, if needed.*