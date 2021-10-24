# =============================        
# Markov Chain Model
# ============================= 
ngram_mc_DT <- function(text.input,freq.table,nwords,len=3){
        
        
        text.input <- iconv(text.input, from = "UTF-8", to = "ASCII", sub = "")
        text.token <- tokens(char_tolower(text.input), 
                             remove_punct = TRUE, 
                             remove_symbols = T, 
                             remove_separators = T, 
                             remove_twitter = T, 
                             remove_hyphens = T, 
                             remove_numbers = T)
        
        text.token <- as.vector(unlist(text.token))
        
        text.n <- length(text.token)
        
        nDisc = 0.5
        nloDisc = 0.5
        
        # 1.a Split frequency table by ngram
        #select maximum ngram order to inspect in frequency table
        ngram_max <- min(len+1,max(freq.table$ngram))
        ft_list <- list()
        #create list of ngram frequency tables
        temp <- as.data.table(freq.table); rm(freq.table)
        setkey(temp,ngram)        
        for (j in 1:ngram_max){
                ft_list[[j]] <- temp[.(j)]
        }
        rm(temp)

        # Extract observed n-gram and discounted probability
        i=0
        len <- min(text.n,len)
        if(len>0){i = text.n-len}
        while (0 < text.n - i){
                #convert text input into ngram format
                text.ngram <- paste0(tail(text.token,text.n-i),collapse="_")
                
                message("Searching for ngram... ", text.ngram)
                
                ngram.search <- grepl(paste0("^",text.ngram,"_"),ft_list[[max(text.n - i + 1,1)]]$feature)
                # =============================
                # If word exists in corpus - Katz Back-Off Model
                # =============================        
                if(sum(ngram.search)>0){
                        ngram_pred <- ft_list[[max(text.n - i + 1,1)]][ngram.search,] %>% 
                                mutate(next.word = gsub(paste0("^",text.ngram,"_"),"",feature)) %>%
                                arrange(desc(frequency))
                        return(ngram_pred[1:min(nwords,nrow(ngram_pred)), "next.word"])  
                }
                i = i + 1
        }
        message("Running Unigram Model")                                
        ngram_pred <- unigram_pred(ft_list[[1]],text.token)
        return(ngram_pred[1:min(nwords,nrow(ngram_pred)), "next.word"])        
        
}


