#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)
library(shinythemes)
library(dplyr)
library(stringr)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    
    theme = shinytheme("slate"),
    
    tags$head(
        
        tags$style(type="text/css", "#text{ height: 200px; word-wrap: break-word; }"),
        
        tags$style(type="text/css", "#value{ height: 200px; word-wrap: break-word; }")
        
    ),     
    
    navbarPage(

        "Word Prediction App",
        ##########
        ## Page 1
        ##########        
        tabPanel(
            "Home",
            sidebarLayout(position = "left",
                mainPanel("", width = 1),
                sidebarPanel(
                    "Hi, I'm a word prediction app. I can help you type phrases on your chosen platform (click on word tabs below to complete phrase).",
                    # Text input box
                    textAreaInput("text_input", "Enter text:", rows = 3),
                    # Action buttons with text output
                    actionButton("word1",label=textOutput("word1"), width = '19%'),
                    actionButton("word2",label=textOutput("word2"), width = '19%'),
                    actionButton("word3",label=textOutput("word3"), width = '19%'),
                    actionButton("word4",label=textOutput("word4"), width = '19%'),
                    actionButton("word5",label=textOutput("word5"), width = '19%'),
                    HTML("<p style='font-size:12px'> <i>(Note: word suggestion tabs above may take a few moments to load...)</i></p>"),
                    # Check Box for Platform
                    radioButtons("platform","Select platform:",
                                 choices = c("Any","Blogs","Twitter")),
                    width = 12
                )
            )
        ),
        
        tabPanel(
            "Documentation",
            mainPanel(htmlOutput('about'))
                
            )
        
    )
))
