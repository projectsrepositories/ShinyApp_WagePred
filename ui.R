# 
# Shiny Web Application for Wage Prediction
#
# Author: Sarita Limbu
# UI logic for providing Input data and 
# displaying prediction results. 
#

library(shiny)
library(shinythemes)
library(shinyWidgets)
library(DT)

# UI
fluidPage(theme = shinytheme("united"),
  setBackgroundColor(
    color = c("#FFEEDD", "#FFFFFF"),
    gradient = "linear",
    direction = c("right")
  ),
  tags$head(
    tags$style(HTML("
                    hr {border-top: 2px solid #000000;}
    "))
  ),
  
  # Navigation bar with two tabs        
  navbarPage("Wage Prediction", collapsible = TRUE,
    windowTitle = "Wage Predictor",
    
    # Tab for prediction
    tabPanel("Home",
      sidebarLayout(
        sidebarPanel(
          
          # Upload the input file for test data
          HTML("<h4><b>1. Upload <i>.csv</i> file</b></h4>"),
          fileInput("upload", NULL, accept = ".csv"),
          actionButton("predbutton1", "Predict Wage", 
                       class = "btn btn-primary"),
          br(),
          hr(),
          
          #  Select the input parameters for a single test data
          HTML("<h4><b>2. Input Parameters</b></h4>"),
          sliderInput("age", "Age",
                      min = 18, max = 100,
                      value = 30),
          selectInput("maritl", label = "Marital Status:", 
                choices = list("Never Married" = "1. Never Married", 
                               "Married" = "2. Married", "Widowed" = "3. Widowed",
                               "Divorced" = "4. Divorced", 
                               "Separated" = "5. Separated")),
          selectInput("race", label = "Race", 
                choices = list("White" = "1. White", 
                               "Black" = "2. Black", "Asian" = "3. Asian",
                               "Other" = "4. Other")),
          selectInput("education", label = "Education", 
                choices = list("< HS Grad" = "1. < HS Grad","HS Grad" = "2. HS Grad",
                               "Some College" = "3. Some College", 
                               "College Grad" = "4. College Grad",
                               "Advanced Degree" = "5. Advanced Degree")),
          selectInput("jobclass", label = "Job Class", 
                choices = list("Industrial" = "1. Industrial", 
                               "Information" = "2. Information")),
          actionButton("predbutton2", "Predict Wage", 
                       class = "btn btn-primary")
        ),
        
        # Display the prediction results and download options 
        mainPanel(
          HTML("<h4><b>Wage Prediction Model built on <u>Wage</u> data from <i>ISLR</i> package.</b></h4>"),
          uiOutput('text'),
          textOutput("filevalid"),
          dataTableOutput('predTable')
        ) 
      )
    ),
    
    # Tab for displaying the about.md page
    tabPanel("About", 
             div(includeMarkdown("about.md"), 
                 align="justify")
    ) 
  )
)















