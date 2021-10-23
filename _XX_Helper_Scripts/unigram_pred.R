# =============================        
# Generate prediction from most frequent words in corpus
# =============================  
unigram_pred <- function(freq.table,text.input){
        ngram_pred <- freq.table %>% filter(ngram == 1) %>% mutate(prob.pred = frequency / sum(frequency),
                                                           feature.pred = paste(text.input,feature,sep="_"),
                                                           next.word = feature) %>%
        select(feature,frequency,feature.pred,prob.pred,next.word) %>% arrange(desc(prob.pred))
        
        return(ngram_pred)
}