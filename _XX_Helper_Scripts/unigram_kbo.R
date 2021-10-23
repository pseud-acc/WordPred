# =============================        
# Unigram Katz Back-Off Model
# ============================= 
unigram_KBO <- function(freq.table,text.input,text.ngram,ngram_Obs_pred){
        prob_mass<- data.frame(alpha= 1 - sum(ngram_Obs_pred$prob.pred))
        ngram_Bo_unObs <- freq.table %>% filter(ngram == 1, !(feature %in% ngram_Obs_pred$next.word)) %>% 
                mutate(prob.pred = prob_mass$alpha * frequency / sum(frequency),
                       next.word = feature, feature.pred = paste(feature,text.ngram,sep="_")) %>%
                select(feature,frequency,feature.pred,prob.pred,next.word)
        ngram_Bo_unObs
        ngram_pred <- ngram_Obs_pred %>% select(feature,frequency,feature.pred,prob.pred,next.word) %>%
                rbind(ngram_Bo_unObs) %>% arrange(desc(prob.pred))
        return(ngram_pred)
}