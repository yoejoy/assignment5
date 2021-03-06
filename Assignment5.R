library(nortest) # install package for normality test

#based on the "rule of thumb", try 30 sample size with poisson distribution
set.seed(47)
lambda <- 5
n <- 30 ; rows <- 1000 #1,000 trails, sample size = 30 each

sim <- rpois(n*rows, lambda)
m <- matrix(sim, rows)

sample.means <- apply(m, 1, mean)

ad.test(sample.means) #try with AD test

#use ADGofTest to draw out p-value

set.seed(47)
lambda <- 5
rows <- 1000 #1,000 trails, sample size = 30 each

n <- 30
for (i in (30:1)){
  sim <- rpois(n*rows, lambda)
  m <- matrix(sim, rows)
  sample.means <- apply(m, 1, mean)
  ad.test(sample.means)
  pvalue <- ad.test(sample.means)$p.value
  {
    if  (pvalue > 0.05){ #if P-value less than or equals to 0.05, the normality test failed
      n <- n-1
    }
  }
}

#n is the (smallest) number of sample size that needed at least to generate normal distribution
n

hist(rpois(n*rows, lambda), freq=FALSE, breaks=100, col="lightblue", main="Density with n samples")

#problem2
library(ggplot2)

set.seed(50)

x <- runif(100000, min = 2, max = 4)
y <- 1/x
xmean <- lapply(x,mean)

hist(y, freq=FALSE, breaks=100, col="pink", main="Frequency of y")
lines(density(y), col="lightblue", lwd=2) # add a density estimate with defaults

plot(x, xmean, col="darkorange", xlab="", ylab="sample means of x",
     type="l",lwd=2, cex=2, main="means of ramdom uniform distribution", cex.axis=.8)

plot(x, y, col="darkgreen",xlab="", ylab="y",
      type="l",lwd=2, cex=2, main="x distribution vs. y distribution", cex.axis=.8)


#problem3
library(shiny)
set.seed(50)
server <- function(input, output) {
  data <- reactive({
    dist <- switch(input$dist,
                   norm = rnorm,
                   studentt = rt,
                   rnorm)
    
    dist(input$n)
  })
  
  
  output$plot <- renderPlot({
    dist <- input$dist
    n <- input$n
    
    hist(data(), 
         main=paste('r', dist, '(', n, ')', sep=''))
  })
  
  # Generate a summary of the data
  output$summary <- renderPrint({
    summary(data())
  })
  
  # Generate an HTML table view of the data
  output$table <- renderTable({
    data.frame(x=data())
  })
  
}

ui <- fluidPage(
  
  # Application title
  titlePanel("Tabsets"),
  
  
  sidebarLayout(
    sidebarPanel(
      radioButtons("dist", "Distribution type:",
                   c("Normal" = "norm",
                     "studentt" = "rt")),
      br(),
      
      sliderInput("n", 
                  "Number of observations:", 
                  value = 100,
                  min = 1, 
                  max = 1000)
    ),
    
    # Show a tabset that includes a plot, summary, and table view
    # of the generated distribution
    mainPanel(
      tabsetPanel(type = "tabs", 
                  tabPanel("Plot", plotOutput("plot")), 
                  tabPanel("Summary", verbatimTextOutput("summary")), 
                  tabPanel("Table", tableOutput("table"))
      )
    )
  )
)

shinyApp(ui = ui, server = server)

#problem4 
data<-scan('productsales.dat')

library(boot)

funmedian <- function(dat,index){
  x = dat[index]
  return(median(x))
}

boot(data,funmedian,R=10000)
boot1 <- boot(data,funmedian,R=10000)

print(boot1)

# the bootstrap estimates of root MSE
sqrt(mean((boot1$t-boot1$t0)^2))

# mean absolute error
mean(abs(boot1$t-boot1$t0))
