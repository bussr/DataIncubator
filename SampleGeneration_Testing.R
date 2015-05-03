

# simulate survey data for 30 questions
# responses scale 1-7
# Think about how to introduce biases to these responses. Factors? Correlated responses?

generate.sample <- function(n = 100, scale.min = 1, scale.max = 7, responses=30){
  
  sample.data = data.frame()
  
  
  for(subject in 1:n){
    #subj = vector(length = responses)
    
    #change this to bias generation of answers
    subj = sample(x = scale.min:scale.max, size = responses, replace = T)
    
    #add subject number as first element in vector
    subj = c(subject, subj)
    sample.data = rbind(sample.data, subj)
  }
  
  colnames(sample.data) = c("Subject", paste("q", 1:responses, sep=""))
  return(sample.data)
  
}