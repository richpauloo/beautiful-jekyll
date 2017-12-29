---
layout: post
title: Test Rmd to markdown
subtitle: I had to manually insert the yaml header
tags: [random, test]
gh-repo: richpauloo/richpauloo.github.io
gh-badge: [star, fork, follow]
---

This is a Test Post
===================

**Let's include bold text** and *italics*

> maybe a block quote

Just to see how things work and if .Rmd works

what about some code?

    library(ggplot2)
    library(dplyr)

    ## Warning: package 'dplyr' was built under R version 3.4.1

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

    iris$Sepal.Length %>% hist()

![](2017-12-26-test-Rmd-post_files/figure-markdown_strict/unnamed-chunk-1-1.png)

    iris %>% distinct(Sepal.Length) %>% 
      merge(iris, by = "Sepal.Length") %>% 
      ggplot() +
      geom_violin(mapping = aes(x = Species, y = Sepal.Length))

![](2017-12-26-test-Rmd-post_files/figure-markdown_strict/unnamed-chunk-1-2.png)
