library(rsconnect)

rsconnect::setAccountInfo(name="pseud-acc", 
                          token="<TOKEN>", 
                          secret="<SECRET>")

deployApp("WordPredApp")
