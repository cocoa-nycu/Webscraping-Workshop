############################################################
# Web Scraping in R
#
# Main packages:
# - httr2: send HTTP requests and receive webpage responses
# - rvest: parse HTML and extract elements with CSS selectors
# - dplyr / tibble: organize scraped data into tables
# - stringr: clean text strings
############################################################

############################################################
# 1. Install and import libraries
############################################################
library(httr2)
library(rvest)
library(xml2)
library(dplyr)
library(purrr)
library(stringr)
library(tibble)


############################################################
# 2. Download a webpage
############################################################

# A webpage is sent from a web server to your computer as HTML.
#
# request() creates a request object.
# req_user_agent("Mozilla/5.0") tells the server who you are.
# req_timeout(5) stops waiting if the server takes too long.
# req_perform() sends the request and gets the response.

response <- request("https://dcat.nycu.edu.tw/members/faculty-and-staff/") |>
  req_user_agent("Mozilla/5.0") |>
  req_timeout(5) |>
  req_perform()

# Check the HTTP status code.
# A status code of 200 usually means the request was successful.
resp_status(response)

# Common HTTP status codes:
# 200: OK - request succeeded
# 201: Created - resource created
# 204: No Content - success, no response body
# 301: Moved Permanently - permanent redirect
# 302: Found - temporary redirect
# 400: Bad Request - invalid request
# 401: Unauthorized - login/authentication required
# 403: Forbidden - not allowed
# 404: Not Found - resource missing
# 429: Too Many Requests - rate limited
# 500: Internal Server Error - server error
# 502: Bad Gateway - bad upstream response
# 503: Service Unavailable - server overloaded or down
# 504: Gateway Timeout - upstream timeout

# Extract the HTML response body as a string.
html_text <- resp_body_string(response)

# Print the raw HTML.
# This may be very long.
cat(html_text)


############################################################
# 3. Parse the HTML with rvest
############################################################

# Raw HTML is just a long string.
# read_html() turns that string into a structure that we can search.

html <- read_html(html_text)

# The page title is a simple first check that rvest is working.
html |>
  html_element("title") |>
  html_text()


############################################################
# 4. Inspect the HTML
############################################################

# On this page, a member name can appear inside an HTML element like this:
#
# <h5 class="brxe-ydknxx brxe-post-title member-list-name">賴至慧(系主任)</h5>
#
# Important parts:
# - h5 is the tag name
# - class="... member-list-name" marks the element as a member name
# - 賴至慧(系主任) is the visible text
#
# In rvest, ".member-list-name" means:
# find elements with class member-list-name.

# Find the first member name element.
first_name_tag <- html |>
  html_element(".member-list-name")

first_name_tag

# Extract only the visible text.
first_name_tag |>
  html_text2()


############################################################
# 5. Find all member name elements
############################################################

# Now that one element works, we can find all elements with the same class.
# html_elements() returns all matching elements.

name_tags <- html |>
  html_elements(".member-list-name")

# Use a for loop to extract text from each element.
names <- c()

for (tag in name_tags) {
  names <- c(names, tag |> html_text2())
}
names

############################################################
# 6. Understand the surrounding structure
############################################################

# A common scraping strategy is:
# 1. Find the target element
# 2. Look at nearby HTML
# 3. Decide where the related information is stored
#
# Here, we inspect the parent area around one name.
# xml_parent() comes from the xml2 package and works with rvest HTML nodes.

first_member_area <- first_name_tag |>
  xml_parent()

# Print only the first 2,000 characters so the output is readable.
cat(as.character(first_member_area) |> str_sub(1, 2000))


############################################################
# 7. Extract profile links
############################################################

# Some names are inside links.
# A link is stored in an <a> tag.
# The href attribute usually stores the profile URL.
# Use html_attr() to get an attribute.

# Solve one element first.
name_tags[[2]] |>
  xml_parent() |>
  html_attr("href")

# Apply the same logic to every name element.
links <- c()

for (name_tag in name_tags) {
  new_link <- name_tag |>
    xml_parent() |>
    html_attr("href")

  links <- c(links, new_link)
}

links

# Store the scraped names and links in a table.
df <- tibble(
  name = names,
  link = links
)

df


############################################################
# 8. Crawling profile pages for email addresses
############################################################

# Sometimes information is stored inside separate pages.
# We can build a crawler to visit profile links one by one.
#
# To get an email link, use this CSS selector:
#
# a[href^="mailto:"]
#
# Meaning:
# - a selects <a> hyperlink tags
# - [href ...] selects links that have an href attribute
# - ^= means "starts with"
# - "mailto:" is the starting text we are looking for

# First, test the idea with one profile page.
response <- request(links[1]) |>
  req_user_agent("Mozilla/5.0") |>
  req_timeout(5) |>
  req_perform()

html <- response |>
  resp_body_string() |>
  read_html()

# Find the first mailto link on the page.
html |>
  html_element('a[href^="mailto:"]')

# To extract the email address, get the href value and remove "mailto:".
html |>
  html_element('a[href^="mailto:"]') |>
  html_attr("href") |>
  str_remove("^mailto:")

# Now repeat for the first three profile links.
# This is intentionally small for teaching, so we do not send too many requests.
for (link in links[1:3]) {
  response <- request(link) |>
    req_user_agent("Mozilla/5.0") |>
    req_timeout(5) |>
    req_perform()

  html <- response |>
    resp_body_string() |>
    read_html()

  tag <- html |>
    html_element('a[href^="mailto:"]')

  email <- tag |>
    html_attr("href") |>
    str_remove("^mailto:")

  print(email)
}

############################################################
# 9. A realistic example: scrape news links from LTN
############################################################

# Let's get some news data from Liberty Times Net.
# Target page:
# https://news.ltn.com.tw/list/breakingnews/politics

response <- request("https://news.ltn.com.tw/list/breakingnews/politics") |>
  req_user_agent("Mozilla/5.0") |>
  req_timeout(5) |>
  req_perform()

resp_status(response)

html <- response |>
  resp_body_string() |>
  read_html()

# First inspect one title element.
html |>
  html_element(".title") |>
  html_text2()

# After we can extract one link, we can extract all of them.
tags <- html |>
  html_elements(".title")

news_links <- c()

for (tag in tags) {
  new_link <- tag |>
    xml_parent() |>
    xml_parent() |>
    html_attr("href")

  news_links <- c(news_links, new_link)
}

news_links


############################################################
# 10. Get one article
############################################################

# Visit one article page.
# Note: article URLs can become outdated over time. If this URL fails,
# replace it with one link from news_links above.

response <- request("https://news.ltn.com.tw/news/politics/breakingnews/5476751") |>
  req_user_agent("Mozilla/5.0") |>
  req_timeout(5) |>
  req_perform()

html <- response |>
  resp_body_string() |>
  read_html()

# Extract the article title.
html |>
  html_element("h1") |>
  html_text2()

# Extract paragraph elements from the article page.
html |>
  html_elements("p") |>
  html_text2()
