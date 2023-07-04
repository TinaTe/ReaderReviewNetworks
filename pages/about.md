---
layout: page
title: Data
permalink: /data/
feature-img: "assets/img/header/darknet.png"
---
* TOC
{:toc}

# Data Structure
The following table shows the structure of the data used in the analysis. The table includes the data on the reviews that were tagged at least once for direct and positive absorption and described books that belong to the five genres under investigation(Fantasy, Romance, Horror/Thriller, Mystery). <br>The first three columns give general information about the review: Column 1 (link) is an identifier for the title-page of a book on Goodreads (https://www.goodreads.com/book/show/”link”), Column 2 (round) denotes the annotation round, in which the annotators processed the review, Column 3 (title) contains the full title of the book in question, Column 4 (plotable_title) presents a short form of the title, which is used as to not overcrowd visualizations, and Column 5 (review) contains an unique identifier for the review at hand. The next columns contain information about the annotated statement: Column 5 (mode) denotes whether there is a direct absorption statement or absorption was mentioned, Column 6 (presence) indicates whether the statement affirms or negates absorption, Column 7 (SWAS_category) holds the absorption dimension and Column 8 (SWAS_tag) the fine-grained category the statement was annotated with, Column 9 (statement) contains the annotated text-segment and Columns 10 and 11 signify the character-index of the absorption statements inside the full review. Lastly, Column 12 (genre) holds the genre the book in question was mostly tagged as and Column 13 (full_review) contains the full review. However, to protext the privacy of the respective reviewers, the full review is not displayed here.
<br> The table can be sorted by clicking on one of the columns.
{% include overview_data.html %}
# Overview
Since Fantasy was massively overrepresented in the data, it was filtered to exclude books that are attributed to one of the other genres in the second or third genre ascription.  
{% include genre_overview.html %}
{% include genre_filtered_overview.html %}
## Distribution of Annotations
test
<iframe src="https://tinate.github.io/jubilant-octo-doodle/" height="600" width="100%"></iframe>
