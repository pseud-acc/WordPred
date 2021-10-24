# =============================        
# Dynamic Katz Back-Off Model
# ============================= 
ngram_kbo_DT <- function(text.input,freq.table,nwords,len=3){
        
        
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
        
        nDisc = 0.2
        nloDisc = 0.2
        
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
                text.ngram.lo <- paste0(tail(text.token,text.n-i-1),collapse="_")
                
                message("Searching for ngram... ", text.ngram)
                
                # 1b. Create dynamic ngram tables
                freq.table_lo_p1 <- ft_list[[max(text.n - i + 1,1)]]
                freq.table_lo <- ft_list[[max(text.n - i,1)]]
                freq.table_lo_m1 <- ft_list[[max(text.n - i - 1,1)]]
                freq.table_uni <- ft_list[[1]]
                
                ngram_match <- freq.table_lo %>% filter(feature == text.ngram) # %>% top_n(1,frequency)
                ngramlo_match <- freq.table_lo_m1 %>% filter(feature == text.ngram.lo) # %>% top_n(1,frequency)
                # =============================
                # If word exists in corpus - Katz Back-Off Model
                # =============================        
                if(nrow(ngram_match)>0){
                        
                        message("Starting Katz Back-Off Model")
                        
                        # 2. find observed ngram predictions (i.e. (n+1)-gram) and compute discounted probability
                        ngram_Obs_pred <- freq.table_lo_p1 %>% filter(grepl(paste0("^",text.ngram,"_"),feature)) %>%
                                dplyr::mutate(prob.pred = ((frequency - nDisc) / ngram_match$frequency),
                                              next.word = gsub(paste0("^",text.ngram,"_"),"",feature), feature.pred = feature) 
                        # =============================        
                        # If text input is a single word - Unigram Katz Back-Off Model
                        # =============================                         
                        if (nrow(ngram_Obs_pred)>0 && text.n-i == 1){
                                message("Running Unigram Katz Back-Off Model")
                                ngram_pred <- unigram_KBO(freq.table_uni,text.token,text.ngram,ngram_Obs_pred)
                                return(ngram_pred[1:min(nwords,nrow(ngram_pred)), c("next.word","prob.pred")])
                                
                                # =============================        
                                # Dynamic Katz Back-Off Model
                                # =============================                            
                        } else if (nrow(ngram_Obs_pred)>0 && text.n-i > 1) {
                                
                                message("Running Dynamic Katz Back-Off Model")
                                
                                # 3. find unobserved n-gram predictions i.e. possible (n+1) word of n-gram input
                                #    Need to extract unigrams not in list of predicted next word from observed ngram predictions 
                                ngram_unObs_tail <- freq.table_uni %>% filter(!(feature %in% ngram_Obs_pred$next.word))
                                # 4. Calculate discounted probability mass - weighting for unobserved n-grams
                                #    Computed from observed n-grams that form the tail (i.e. n-1) of the n-gram input
                                prob_mass <- freq.table_lo %>% filter(grepl(paste0("^",text.ngram.lo,"_"),feature)) %>%
                                        summarise(alpha = 1 - (sum(frequency - nloDisc) / ngramlo_match$frequency))
                                # 5. Calculate backed-off probabilities for n-grams
                                # 5a. Generated backed-off n-grams using the unobserved (n+1)-gram tails - see (3)
                                ngram_Bo <-ngram_unObs_tail %>% dplyr::mutate(feature.BO.ngram = paste(text.ngram.lo, feature, sep = "_"))
                                # 5b. Extract observed frequencies of backed-off n-grams
                                ngram_Bo_Obs <- freq.table_lo %>% filter(feature %in% ngram_Bo$feature.BO.ngram,
                                                                         str_count(feature,"_") > 0)
                                # 5c. Identify unobserved backed-off n-grams - using 5b
                                ngram_Bo_unObs <- ngram_Bo %>% filter(!(feature.BO.ngram %in% ngram_Bo_Obs$feature)) %>% 
                                        dplyr::mutate(feature =  feature.BO.ngram) %>% select(-feature.BO.ngram)
                                # 5d. Generate probabilities of observed backed-off n-grams
                                ngram_Bo_Obs <- ngram_Bo_Obs %>% dplyr::mutate(prob  = ifelse(frequency>0,(frequency - nloDisc) / ngramlo_match$frequency,0))
                                # 5e. Generate probabilities of unobserved backed-off n-grams 
                                ngram_Bo_unObs <-ngram_Bo_unObs %>% dplyr::mutate(prob = prob_mass$alpha * frequency / sum(frequency) )
                                # Combine observed and unobserved n-grams
                                ngram_Bo <- rbind(ngram_Bo_Obs,ngram_Bo_unObs)
                                # 6. Calculate (n+1)-gram probability discount mass - using observed (n+1)-gram probabilities
                                prob_mass <- prob_mass %>% dplyr::mutate(alpha2 = 1 - sum(ngram_Obs_pred$prob.pred))
                                # 7. Calculate unobserved backed-off (n+1)-gram probabilities
                                ngram_Bo_unObs_pred <- ngram_Bo %>% dplyr::mutate(feature.pred = paste(text.token[1],feature,sep="_"),
                                                                                  prob.pred = prob_mass$alpha2*prob / sum(prob))
                                # 8. Select prediction with highest probability
                                # Clean data frames
                                ngram_Bo_unObs_pred <- ngram_Bo_unObs_pred %>% dplyr::mutate(next.word = sub(".*_", "",feature.pred)) %>%
                                        select(feature,frequency,feature.pred,prob.pred,next.word)
                                ngram_pred <- ngram_Obs_pred %>% select(feature,frequency,feature.pred,prob.pred,next.word) %>% 
                                        rbind(ngram_Bo_unObs_pred) %>% arrange(desc(prob.pred))
                                return(ngram_pred[1:min(nwords,nrow(ngram_pred)), c("next.word","prob.pred")])
                        }
                }
                i = i + 1
        }
        message("Running Unigram Model")                                
        ngram_pred <- unigram_pred(freq.table_uni,text.token)
        return(ngram_pred[1:min(nwords,nrow(ngram_pred)), c("next.word","prob.pred")])        
        
}


