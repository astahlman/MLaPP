d <- read.csv('/Users/astahlman/Documents/Programming/ML/murphy/ch4/heightWeight.csv', sep=",", header=TRUE)
males <- d[which(d$sex == 1),]
require('plyr')

# 1 = Male
# 2 = Female
x1 <- males$height.inches
x2 <- males$weight

means <- ddply(d, .(sex), numcolwise(mean))
sds <- ddply(d, .(sex), numcolwise(sd))

male.height.mean <- means[1,"height.inches"]
male.weight.mean <- means[1, "weight"]
male.height.sd <- sds[1,"height.inches"]
male.weight.sd <- sds[1,"weight"]

bivariate <- function(x,y){
    mu1 <- mean(x1)
    mu2 <- mean(x2)
    sig1 <- sd(x1)
    sig2 <- sd(x2)
    rho <- cor(x1, x2)
    term1 <- 1 / (2 * pi * sig1 * sig2 * sqrt(1 - rho^2))
    term2 <- (x - mu1)^2 / sig1^2
    term3 <- -(2 * rho * (x - mu1)*(y - mu2))/(sig1 * sig2)
    term4 <- (y - mu2)^2 / sig2^2
    z <- term2 + term3 + term4
    term5 <- term1 * exp((-z / (2 *(1 - rho^2))))
    return (term5)
}

x1.range <- seq(min(x1), max(x1), length=100)
x2.range <- seq(min(x2), max(x2), length=100)


dist <- outer(x1.range, x2.range, bivariate)

plot.normal <- function() {
    plot(x=x1,y=x2)
    contour(dist, x=x1.range, y=x2.range, col=terrain.colors(11),add=T)
}

# Standardized
plot.std <- function() {
    z1 <- (x1 - mean(x1)) / sd(x1)
    z2 <- (x2 - mean(x2)) / sd(x2)
    z1.range <- seq(min(z1), max(z1), length=100)
    z2.range <- seq(min(z2), max(z2), length=100)

    plot(x=z1,y=z2)
    contour(dist, x=z1.range, y=z2.range, col=terrain.colors(11),add=T)
}
