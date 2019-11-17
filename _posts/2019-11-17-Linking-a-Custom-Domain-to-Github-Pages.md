---
share-img: "https://miro.medium.com/proxy/1*iZAdDbTxR8TOEf2X_W0kHA.jpeg"
layout: post
---


Here's a boilied down method to configure add a custom domain (e.g., username.com) to your github pages website (e.g., username.github.io).   

# Step 1

Buy a domain (e.g., richpauloo.com). I used godaddy.com, but you can use any number of domain name registries.  

# Step 2  

In your github.io repository Settings, add the domain you purchased in Step 1 to the "Custom domain box":  

<center>
<img src="/img/cd.png" alt="custom domain with github pages tutorial" width="100%"/> 
</center>

Make sure you do Step 2 before Step 3, for security reasons outlined in the [Official Github docs](https://help.github.com/en/github/working-with-github-pages/managing-a-custom-domain-for-your-github-pages-site#about-custom-domain-configuration).  

# Step 3 

In your DNS Management console, add a CNAME record with the following parameters:  

* type = CNAME
* name = www
* value = username.github.io.


<center>
<img src="/img/cn.png" alt="custom domain with github pages tutorial" width="100%"/> 
</center>

**Meaning:** This tells your DNS to point www.username.com requests towards the site hosted at username.github.io. Set the TTL (time to live) to an hour or less.  

Next, in your DNS Management console, add 4 separate A records with the following information:  

* type = A  
* name = @  
* points to (value) = IP   
  

<center>
<img src="/img/ar.png" alt="custom domain with github pages tutorial" width="100%"/> 
</center>

For IP, supply the Github IP addresses that host your username.github.io site. As of writing (2019-11-15) these IPs are: 

```
185.199.108.153
185.199.109.153
185.199.110.153
185.199.111.153
```

However the values might have changed since the time of writing. See the [offical docs](https://help.github.com/en/github/working-with-github-pages/managing-a-custom-domain-for-your-github-pages-site#about-custom-domain-configuration) for the most up-to-date values.  

**Meaning:** "A" records connect your domain name (hosted by your DNS) to the actual IP addresses where your site lives on a server (at Github).  

# Step 4

Nagivate to username.com to see your github page! Be patient if it doesn't immediately show. This lag is related to [DNS propogration](https://www.namecheap.com/support/knowledgebase/article.aspx/9622/10/dns-propagation--explained). 

***  


Here are three resources I found helpful while doing this:

1. [Offical docs](https://help.github.com/en/github/working-with-github-pages/managing-a-custom-domain-for-your-github-pages-site#about-custom-domain-configuration)
2. [An unoffical guide](https://medium.com/@hossainkhan/using-custom-domain-for-github-pages-86b303d3918a).  
3. [Nice explanation of A records](https://www.godaddy.com/help/add-an-a-record-19238)