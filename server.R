# 
# Shiny Web Application for Wage Prediction 
#
# Author: Sarita Limbu
# Server logic to 
#     1. retrieve data from UI, 
#     2. run the saved RF regression model, 
#     3. predict the wage results,
#     4. make the result data available for download in desired format.
#

library(shiny)
library(shinyjs)
library(data.table)
library(DT)

# Read the RF model
model <- readRDS("model.rds")

# Initialize variables to be used in two eventReactive() functions
level_maritl<- c("1. Never Married", 
                 "2. Married", 
                 "3. Widowed", 
                 "4. Divorced",
                 "5. Separated")
level_race  <- c("1. White", 
                 "2. Black", 
                 "3. Asian", 
                 "4. Other")
level_education <- c("1. < HS Grad", 
                     "2. HS Grad", 
                     "3. Some College", 
                     "4. College Grad", 
                     "5. Advanced Degree")
level_jobclass <- c("1. Industrial", 
                    "2. Information")

# Server
server<- function(input, output, session) {
  
  # Initialize reactiveValues to keep track of the last button clicked
  rv <- reactiveValues(lastBtn = "None")
  
  # Keep track of the button clicked.
  observeEvent(input$predbutton1, {
    if (input$predbutton1 > 0 ) {
      rv$lastBtn = "btn1"
    }
  })
  observeEvent(input$predbutton2, {
    if (input$predbutton2 > 0 ) {
      rv$lastBtn = "btn2"
    }
  })
  
  # Validate the uploaded file type/extension
  valid <- reactive({
    req(input$upload)
    ext <- tools::file_ext(input$upload$name)
    if(ext!="csv")
      validate("Invalid file! Only .csv file accepted for prediction.")
    else
      print("")
  })
 
  # Get test data from uploaded file and make prediction
  predict_wage1<-eventReactive(input$predbutton1, {
    input <- vroom::vroom(input$upload$datapath, delim = ",")
    write.table(input,"input.csv", sep=",", quote = FALSE, row.names = FALSE)
    
    test <- read.csv("input.csv", header = TRUE)
    test$maritl <- factor(test$maritl, levels = level_maritl)
    test$race <- factor(test$race, levels = level_race)
    test$education <- factor(test$education, levels = level_education)
    test$jobclass <- factor(test$jobclass, levels = level_jobclass)
    Output <- data.frame('Predicted Wage' = round(predict(model,test),2))
    Output <- cbind(test, Output)
    print(Output)
  })
   
  # Get parameters for single test data and make prediction
  predict_wage2 <- eventReactive(input$predbutton2, {
    df <- data.frame(
      Name = c("age",
               "maritl",
               "race",
               "education",
               "jobclass"),
      Value = as.character(c(input$age,
                             input$maritl,
                             input$race,
                             input$education,
                             input$jobclass)),
      stringsAsFactors = FALSE)
    
    input <- transpose(df)
    write.table(input,"input.csv", sep=",", quote = FALSE, row.names = FALSE, 
                col.names = FALSE)
    
    test <- read.csv("input.csv", header = TRUE)
    test$maritl <- factor(test$maritl, levels = level_maritl)
    test$race <- factor(test$race, levels = level_race)
    test$education <- factor(test$education, levels = level_education)
    test$jobclass <- factor(test$jobclass, levels = level_jobclass)
    Output <- data.frame('Predicted Wage' = round(predict(model,test),2))
    Output <- cbind(test, Output)
    print(Output)
  })
  
  # Output the uploaded file type validation
  output$filevalid <- renderText({
    valid()
  })

  # Output the label "Prediction Result"
  output$text <- renderUI({
    if((input$predbutton1>0) || (input$predbutton2>0)) { 
      tags$label(h3('Prediction Result'))
    }
  })
  
  # Output the prediction result table
  output$predTable <- renderDataTable(server=FALSE,
    {
      if(rv$lastBtn == "btn1"){
        print("btn1 clicked")
        predict_wage1()
      }
      else if (rv$lastBtn == "btn2"){
        print("btn2 clicked")
        predict_wage2()
      }
      else
        df <- data.frame()
    },
    extensions = 'Buttons', 
    options = list(
      dom = 'Blrtip',
      buttons = list('copy','print',
                     list(
                       extend = 'collection',
                       buttons = list(
                         list(extend = "csv", filename = "PredictedWage",
                              exportOptions = list(columns = ":visible",
                                                   modifier = list(page = "all"))
                         ),
                         list(extend = 'excel', filename = "PredictedWage",
                              exportOptions = list(columns = ":visible",
                                                   modifier = list(page = "all"))
                         ),
                         list(extend = 'pdf', filename = "PredictedWage",
                              exportOptions = list(columns = ":visible",
                                                   modifier = list(page = "all"))
                         )
                       ),
                       text = 'Download'
                     )
                     
      )
    )
  )
}
