shinyServer(function(input, output) {
  
  # OUTPUT DATA SOURCE

  output$outLastObs <- renderText({
    
    
  })
  
  output$outDataSourceDescription <- renderText({ 
    
    if (input$inputDataSource == "DAX") {
      msgOut<-'<div>
                    <p> Source: <a 
                            href="https://www.quandl.com/data/CHRIS/EUREX_FDAX1-DAX-Futures-Continuous-Contract-1-FDAX1-Front-Month">Quandl</a> </p>
                    <p>The <a href="http://en.wikipedia.org/wiki/DAX">DAX</a> (Deutscher Aktienindex (German stock index)) is a blue chip stock market index consisting of the 30 major German companies trading on the Frankfurt Stock Exchange.</p>
                    </div>'
    } else {
      msgOut<-'<div>
<p> Source: <a href="https://www.quandl.com/data/CHRIS/EUREX_FEU31-Three-Month-EURIBOR-Futures-Continuous-Contract-1-FEU31-Front-Month">Quandl</a> </p>
                    <p> The <a href="http://www.euribor-rates.eu">Euro Interbank Offered Rates (EURIBOR)</a> are based on the average 
                interest rates at which a large panel of European banks borrow funds 
                  from one another.</p>      
                    </div>'
    }
    
    msgOut<-paste("<i>",msgOut,"</i>",sep="")
    msgOut
  })

  # OUTPUT TABLE
  
  output$outContractTable <- renderTable({ 
    
    fileName<- paste(getwd(),"/data/",input$inputDataSource,".csv",sep="")
    
    data<-read.csv(file = fileName, header = TRUE, sep = ",", quote = "\"",
                   dec = ".", fill = TRUE, comment.char = "")
    table<-head(data[,c(2,6,8)])
    colnames(table)<-c("Date","Settle","Open.Int.")
    table
  })

  output$outDescriptiveTable <- renderText({ 
    
    fileName<- paste(getwd(),"/data/",input$inputDataSource,".csv",sep="")
    
    data<-read.csv(file = fileName, header = TRUE, sep = ",", quote = "\"",
                   dec = ".", fill = TRUE, comment.char = "")
    qt<-quantile(data[,c(8)])
    msgOut<-paste("
    <table style='width:35%' border='1' >
      <tr>
      <td align='center'>Min</td>
      <td align='center'>25th percentile</td>
      <td align='center'>75th percentile</td>
      <td align='center'>Max</td>
      <td align='center'>Average</td>
      </tr>
      <tr> 
      <td align='center'>",formatC(qt[1], format="d", big.mark=','),"</td>
      <td align='center'>",formatC(qt[2], format="d", big.mark=','),"</td>
      <td align='center'>",formatC(qt[4], format="d", big.mark=','),"</td>
      <td align='center'>",formatC(qt[5], format="d", big.mark=','),"</td>
      <td align='center'>",formatC(mean(data[,c(8)]), format="d", big.mark=','),"</td>
      </tr>
      </table>",sep="")    
    
  })
  
  output$outDescriptiveComment <- renderText({ 
    
    fileName<- paste(getwd(),"/data/",input$inputDataSource,".csv",sep="")
    
    data<-read.csv(file = fileName, header = TRUE, sep = ",", quote = "\"",
                   dec = ".", fill = TRUE, comment.char = "")
    
    data$Date<-as.Date(data$Date)
    
    pos<-ifelse(data[1,c(8)]>mean(data[,c(8)], na.rm=TRUE), "above", "below")
    adj<-ifelse(data[1,c(8)]>mean(data[,c(8)], na.rm=TRUE), "ample", "scarce")
    
    msgOut<-paste("<p>Some simple descriptive statistics show that the daily average amount of contracts for the entire period (",min(data[,c(2)])," to ",
                  max(data[,c(2)]), ") is ",formatC(mean(data[,c(8)]), format="d", big.mark=','),". ",
                  " The last observed number of open interest (",formatC(data[1,c(8)], format="d", big.mark=','),") indicates that it is ", pos,
                  " the average number."," This difference could be interpreted as ",adj," liquidity. We can also choose to relate the current
                  number of open contracts to any of the statistics depending on the motive of the application (perhaps tail events are of interest; in that case a
                  small or large percentile may be more suitable as a reference point). However, estimating 
                  the level of liquidity using these relative data points provides a rudimentary picture of the market at best. 
                  A fuller picture of the market's liquidity can be conveyed by more data points over time.</p>", sep="")
    
    
  })
  
  
  # OUTPUT PLOT
  output$outContractPlot <- renderPlot({ 
    fileName<- paste(getwd(),"/data/",input$inputDataSource,".csv",sep="")
    #fileName<- paste("/Users/danieleke/Code/R/Shiny/euribor/data/","DAX",".csv",sep="")
    dataPlot<-read.csv(file = fileName, header = TRUE, sep = ",", quote = "\"",
                   dec = ".", fill = TRUE, comment.char = "")
    
    dataPlot$Date<-as.Date(dataPlot$Date)
    dataPlot$Prev..Day.Open.Interest<-as.numeric(dataPlot$Prev..Day.Open.Interest)
    dataPlot$Average<-mean(dataPlot$Prev..Day.Open.Interest)
    #head(dataPlot)
    mdata <- melt(dataPlot[,c(2,8,9)], id=c("Date"))
    head(mdata)
    #gp<-ggplot(data=dataPlot,aes(x=Date,y=Prev..Day.Open.Interest)) + geom_line() +
    gp <- ggplot(mdata) + geom_line(aes(x=Date, y=value, colour=variable)) + scale_y_continuous("Number of Contracts", labels = comma) + 
      scale_x_date(labels = date_format("%Y-%m-%d"), expand = waiver(), breaks = date_breaks("13 weeks")) +
      ggtitle(paste(input$inputDataSource," Futures", sep="")) +
      theme(axis.text.x = element_text(angle = 90, hjust = 1)) + xlab("") +
      theme(legend.position="top")
    
    if (input$uiAddSpline == TRUE){
    gp <- gp + stat_smooth(method = "loess", aes(x=Date,y=value))
    }
    
    gp
    
  })
  })
