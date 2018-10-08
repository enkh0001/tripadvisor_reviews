library(rvest)
options(warn=-1)

url <- "https://www.tripadvisor.com.sg/Attraction_Review-g294265-d324752-Reviews-Esplanade_Theatres_on_the_Bay-Singapore.html"

morepglist <-seq(10,700,10)

pick <- url
# get list of urllinks corresponding to different pages

# url link for first search page
urllinkmain=pick
# counter for additional pages
morepg=as.numeric(morepglist)

urllinkpre=paste(strsplit(urllinkmain,"Reviews-")[[1]][1],"Reviews",sep="")
urllinkpost=strsplit(urllinkmain,"Reviews-")[[1]][2]

urllink=rep(length(morepg)+1)

urllink[1]=urllinkmain
for(i in 1:length(morepg)){
  urllink[i+1]=paste(urllinkpre,"-or",morepg[i],"-",urllinkpost,sep="")
}
head(urllink)
Review_Data <- data.frame()
for (i in 1:71) {
  reviews <- urllink[i] %>%
    read_html() %>%
    html_nodes("#REVIEWS .ui_column.is-9")
   review_id <- reviews %>%
    html_node(".title") %>%
    html_attr("id") 
   title <- reviews %>%
    html_node(".quote .noQuotes") %>%
    html_text()
  rating_date <- reviews %>%
    html_node(".ratingDate") %>%
    html_attr("title") %>%
    strptime("%d %b %Y") %>%
    as.POSIXct()
    numeric_rating<- reviews %>%
    html_node(".ui_bubble_rating")%>%
    as.character()%>%
   substr(start=38,stop=39)%>%
   as.numeric()/10
  review <- reviews %>%
    html_node(".entry .partial_entry") %>%
    html_text()
  webpage <- read_html(urllink[i])
  Review_Data <- rbind(Review_Data, data.frame(review_id, title, rating_date, numeric_rating, review, stringsAsFactors = FALSE))
}
 write.csv(Review_Data, file = "/data/out/tables/Review_Data.csv", row.names = FALSE)
