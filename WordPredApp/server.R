#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(plyr)
library(dplyr)
library(DT)
library(quanteda)
library(devtools)

#Load n-gram frequency tables
url <- "https://github.com/pseud-acc/WordPred/raw/main/data/en_US/ngram_1_2_3_4_ls.rds"
freq.table <- readRDS(gzcon(url(url)))

url <- "https://github.com/pseud-acc/WordPred/raw/main/data/en_US/ngram_1_2_3_4_by_source_ls.rds"
freq.table_by_source <- readRDS(gzcon(url(url)))

#Load Helper Scripts
source_url("https://github.com/pseud-acc/WordPred/raw/main/_XX_Helper_Scripts/ngram_kbo_DF.R")
source_url("https://github.com/pseud-acc/WordPred/raw/main/_XX_Helper_Scripts/ngram_kbo_DT.R")
source_url("https://github.com/pseud-acc/WordPred/raw/main/_XX_Helper_Scripts/ngram_mc_DF.R")
source_url("https://github.com/pseud-acc/WordPred/raw/main/_XX_Helper_Scripts/ngram_mc_DT.R")
source_url("https://github.com/pseud-acc/WordPred/raw/main/_XX_Helper_Scripts/unigram_kbo.R")
source_url("https://github.com/pseud-acc/WordPred/raw/main/_XX_Helper_Scripts/unigram_pred.R")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    
    #Information Page
    output$about <- renderUI({
        HTML(
            ' <p><span style="font-weight:bold">About</span></p>
<pstyle="text-align:justify">This web application predicts the next word of text inputted by the user. </p>

'            
        )
    })
    
    
    word_preds <- reactive({ 
        
        if(input$platform == "Any"){
            freq.table_in <- freq.table
        } else{
            freq.table_in <- freq.table_by_source %>% filter(group == tolower(input$platform))
        }
        
        if (input$text_input %in% c("", " ")){
            freq.table_in[1:5,] %>% mutate( next.word = feature )

        } else {
        
        text.input <- input$text_input
        
        tmp <- ngram_kbo_DF(text.input,freq.table_in,5,3)  
        
        pred.words <- data.frame(next.word = c("","","","",""))
        pred.words$next.word[1:nrow(tmp)] <- tmp$next.word
        
        pred.words
        }
        
    })    
    
    observeEvent(input$word1, {
       x <- word_preds()$next.word[1]
        
        updateTextInput(session, "text_input", value = paste(input$text_input, x))
    })    
    
    observeEvent(input$word2, {
       x <- word_preds()$next.word[2]
        
        updateTextInput(session, "text_input", value = paste(input$text_input, x))
    }) 
    
    observeEvent(input$word3, {
        x <- word_preds()$next.word[3]
        
        updateTextInput(session, "text_input", value = paste(input$text_input, x))
    }) 
    
    observeEvent(input$word4, {
        x <- word_preds()$next.word[4]
        
        updateTextInput(session, "text_input", value = paste(input$text_input, x))
    }) 
    
    observeEvent(input$word5, {
        x <- word_preds()$next.word[5]
        
        updateTextInput(session, "text_input", value = paste(input$text_input, x))
    })     
    
    output$word1 <- renderText({
        word_preds()$next.word[1]
    })
    
    output$word2 <- renderText({
        word_preds()$next.word[2]
    })
    
    output$word3 <- renderText({
        word_preds()$next.word[3]
    })
    
    output$word4 <- renderText({
        word_preds()$next.word[4]
    })
    
    output$word5 <- renderText({
        word_preds()$next.word[5]
    })    
    

})
