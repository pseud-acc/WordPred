#Function to create n-gram frequency table from tokenised corpus

tokenisation <- function(doc.tokens,ngrams){
        
        # @doc.tokens: quanteda token object
        # @ngrams: vector specifying number of ngrams
        
        output <- list()
        
        # Create n-grams
        output$doc.tokens.ngram <- tokens_ngrams(doc.tokens, n=ngrams)
        
        # Converting to a DFM
        output$doc.dfm <- dfm(output$doc.tokens.ngram)
        
        # Create frequency tables
        output$freq.ngram <- tibble(textstat_frequency(output$doc.dfm, groups = origin))
        
        output$freq.table_by_group <- output$freq.ngram %>% group_by(group) %>% 
                mutate(count = sum(frequency), nn = 1) %>% mutate(fd = frequency / count) %>%
                arrange(group, desc(fd)) %>%  mutate(rank = cumsum(nn), rankf = rank / max(rank),
                                                     fds = cumsum(fd),
                                                     ngram = str_count(feature,"_")+1)
        
        output$freq.table <- output$freq.ngram %>% group_by(feature) %>% 
                summarise(frequency = sum(frequency)) %>% arrange(desc(frequency)) %>%
                mutate(fd = frequency / sum(frequency), fds = cumsum(fd), nn = 1,
                       rank = cumsum(nn), rankf = rank / max(rank), group = "All",
                       ngram = str_count(feature,"_")+1)
        
        return(output)
        
}