library(shiny)
library(Quandl)
library(ggplot2)
library(scales)
library(reshape)

shinyUI(fluidPage(
  titlePanel("An Analytics Solution for a Liquidity Stress Index"),
      a("A showcase by Daniel Ekeblom", href="http://danielekeblom.com"),
  hr(),
fluidRow(
  column(4,
         wellPanel(
         h4("THE TECHNICAL APPLICATION"),
         p("This page demonstrates the three schematic steps that go into building an analytics
    App for measuring liquidity stress in a given market."),
         HTML('<p>The three steps are equivalent for any solution that:
              <ul>
                <li>takes a clean data set</li>
                <li>performs some computation using that data</li>
                <li>presents the results to the end user</li>
              </ul>
              <p>'),
         HTML('<p>This App has been built using <a href="http://www.rstudio.com">R Studio</a>, 
                 <a href="http://shiny.rstudio.com">Shiny</a> and 
              <a href="http://getbootstrap.com">Bootstrap</a>, hosted on a Virtual Private Server.
              This solution is suitable for cases that require business logic 
              to occur on the server side, and where the client side mainly 
              renders information to a limited number of end users.</p>')
  )
    ),
  column(4,wellPanel(
         h4("THE BUSINESS CASE"),
         HTML("<p>This case demonstrates a simple exercise in choosing a data set that 
                will be used for the construction of 
                      a liquidity measure for European financial markets. 
                  Market liquidity is a market's ability to facilitate the purchase or sale of an asset without causing drastic change in the asset's price (<a href='http://en.wikipedia.org/wiki/Market_liquidity'>Wikipedia</a>). Well functioning markets are often liquid markets. Therefore, investors and policy makers use liquidity indicators to probe if markets are functioning as intended.</p>
              <p>The case exhibits the conceptual choices and pitfalls that a client has to 
                      face when constructing a simple App for this purpose.</p>")
    )),
  column(4,wellPanel(
         HTML('<h4>FEEDBACK <a href="mailto:daniel@ekeblom.net?Subject=Hi, regarding the liquidity showcase on your website"><span class="glyphicon glyphicon-envelope" aria-hidden="true"> </span></a></h4>'),
         HTML('<p>This case is meant to give you an idea of the capabilites of a basic analytics solution. 
              If you have questions regarding this case, please <a href="mailto:daniel@ekeblom.net?Subject=Hi, regarding the liquidity showcase on your website">send me a mail</a> and I will get back to you as soon as I can.</p>')
         ))
),
            hr(),

wellPanel(          HTML("<h4>STEP 1: SOURCING DATA</h4>"),
              HTML('<div>
                    <p>
                  The first step in constructing an App is to choose a data set that will fit the purpose of the App
                  from an appropriate data source. We have sourced two candidate sets containing futures data below from <a 
                            href="https://www.quandl.com">Quandl</a>.'),
                HTML(" Futures are suitable from the point of view that the they contain information on producers' and speculators' expectations.
                    Both sets contain data on futures, with prices at Open, High, Low and Settle, including traded Volume and Open Interest.
                    </p>
                    </div>"),
wellPanel(              radioButtons("inputDataSource", label = h5("SELECT A DATA SET"), 
                          choices = list("DAX Futures" = "DAX",
                                         "EURIBOR Futures" = "EURIBOR"
                                         ), 
                          selected = "DAX")),
              htmlOutput("outDataSourceDescription"),
              br(""),
              h5("SAMPLE CONSISTING OF THE LAST SIX OBSERVATIONS"),
              tableOutput("outContractTable"),
              br(""),
              h5("NOTE"),
              HTML('<div class="panel panel-default panel-success"> 
                      <div class="panel-heading"> <p><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span>
                      - The data source is external to the App. It may reside in a local database or with a third party, 
                        allowing a flexible approach in constructing the data set.</p>
                      </div>
                   </div>'),
              HTML('<div class="panel panel-default panel-danger"> 
                      <div class="panel-heading"> 
                  <p><span class="glyphicon glyphicon-thumbs-down" aria-hidden="true"></span>
                    - The larger and more complex the data source, the more delicate the handling of 
                      the data set becomes. App performance may deteriorate if the data set is too large.</p>
                      </div>
                   </div>')
),
wellPanel(
              HTML('<h4>STEP 2: PERFORMING COMPUTATIONS</h4>'),
              HTML("<div>
                    <p>The data is rarely in such a state that it immediately provides an answer to the end user's question.
                    Therefore, once an appropriate measure is defined, some computation will have to be performed in order to
                    emphasize the relevant dimension.</p>"),
              HTML('For example, we rely on the Open Interest data from the sample to create our liquidity measure. 
                    Open interest refers to the total number outstanding of futures contracts that have not been settled (<a href="http://en.wikipedia.org/wiki/Open_interest">Wikipedia</a>).
                    An increase in the amount of contracts indicates that the amount of capital that is being invested in the market is increasing (i.e. increasing liquidity);
                    a decrease in the amount of contracts indicates that the amount of capital is being reduced (i.e. decreasing liquidity). This hypothesis can be used for the construction of a liquidity index.</p>
                   </div>'),
              h5("SOME SIMPLE DESCRIPTIVE STATISTICS"),
              htmlOutput("outDescriptiveTable"),
              br(""),
              htmlOutput("outDescriptiveComment"),
              br(""),
              h5("NOTE"),
              HTML('<div class="panel panel-default panel-success"> 
                      <div class="panel-heading"> <p><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span>
                      - The computations are normally carried out behind the scenes, which allow for powerful and concise Apps.</p>
                      </div>
                   </div>'),
              HTML('<div class="panel panel-default panel-danger"> 
                      <div class="panel-heading"> 
                  <p><span class="glyphicon glyphicon-thumbs-down" aria-hidden="true"></span>
                    - The ability to hide large parts of the computation can hide the logic of the App and render it unintuitive for the end user.</p>
                  <p><span class="glyphicon glyphicon-thumbs-down" aria-hidden="true"></span>
                    - This step can become cumbersome if the statistical model is elaborate or needs to be validated.</p>
                      </div>
                   </div>')
              ),
wellPanel(              HTML('<h4>STEP 3: PRESENT RESULTS</h4>'),
              p("The results from the computation are often intuitively displayed in some form of chart. 
                One way of depicting the liquidity using the above data points is simply by plotting the actual values for the Open Interest using one line, and the average value using another. It could look something like this."),
              br(""),
wellPanel(              radioButtons("uiAddSpline",label="TREND ESTIMATION USING SPLINE",
                          choices = list("ENABLE" = TRUE, "DISABLE" = FALSE),
                          selected = FALSE)),
              plotOutput("outContractPlot"),
              br(""),
              p("According to this chart, liquidity is ample when the Open Interest line is above the horizontal Average line. 
                Plots like these can be modified with colours and markers depending on 
                the information that should be conveyed to the end user. For instance, you can add a 
                trend line to the chart that will estimate the general trend of the Open Interest line 
                in case it is too noisy."),
              br(""),
              h5("NOTE"),
              HTML('<div class="panel panel-default panel-success"> 
                      <div class="panel-heading"> <p><span class="glyphicon glyphicon-thumbs-up" aria-hidden="true"></span>
                      - A great variety of charts and graph options are available to the end user.</p>
                      </div>
                   </div>'),
              HTML('<div class="panel panel-default panel-danger"> 
                      <div class="panel-heading"> 
                  <p><span class="glyphicon glyphicon-thumbs-down" aria-hidden="true"></span>
                    - Complexity has to be managed in order to avoid wasting resources on nice to have functionality (scope creep)</p>
                      </div>
                   </div>')),
              
              hr(),
              h4("FINAL COMMENT"),
              HTML('<p>This simple showcase is meant to provide you with an idea of the capabilities of a standard Analytics solution. 
              Any of the three steps can be elaborated upon, depending on the need of the project.
              For a proper evaluation of a project, please <a href="mailto:daniel@ekeblom.net?Subject=Hi, regarding the liquidity showcase on your website">send me a mail</a> and I will get back to you as soon as I can.</p>
                     '),
              a("Daniel Ekeblom", href="http://danielekeblom.com"),
              hr()

))