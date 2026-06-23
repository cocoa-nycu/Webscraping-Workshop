# Web Scraping Workshop

This repository contains teaching materials for an introductory workshop on **web scraping**. The workshop is designed for learners who want to understand how information on websites can be collected, parsed, cleaned, and organized into structured data.

The workshop is available in both **Python** and **R**. Learners can choose the language they are more comfortable with. Python and R use different syntax, but the underlying process is the same.

## Learning Goals

By the end of the workshop, learners should be able to:

* Explain the request-response cycle behind webpages
* Understand what HTML is and why it matters for scraping
* Use CSS to locate content on a page
* Extract text and links from webpage elements
* Follow links to collect information from multiple pages

## Prerequisites

Learners should have basic familiarity with either Python or R, including:

* Running code
* Installing and loading packages
* Working with variables
* Reading simple tables or data frames
* Understanding basic functions or loops

No prior experience with HTML, CSS, or web scraping is required.


## Repository contents

This repository includes teaching scripts in both Python and R.

Suggested repository structure:

```text
.
├── README.md
├── webscraping.ipynb
├── webscraping.R
└── Web Scraping.pdf
```

### Python Version

The Python version introduces web scraping using Python packages such as:

* `requests` for downloading webpages
* `BeautifulSoup` for parsing HTML
* `pandas` for cleaning and organizing results

### R Version

The R version follows the same structure and logic using R packages such as:

* `httr2` for sending HTTP requests
* `rvest` for parsing and selecting HTML elements
* `xml2` for navigating HTML node relationships
* `dplyr` for cleaning and organizing results

