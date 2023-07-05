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
Thereby, the number of books was decreased to 13 and the number of corresponding reviews to 58. While still being bigger than the other corpora, this decision was deemed sufficient to balance out the overall corpus. This reduction process was also performed for Romance, but there seemed to be no overlap with the other genres under investigation. What can be noted about the resultant corpus is the number of annotations. Romance seems to have the highest density of annotations, followed by Fantasy and Hor-ror/Thriller, whereas Mystery and Science Fiction appear to have fewer instances of absorbed reading in them.
{% include genre_overview.html %}
{% include genre_filtered_overview.html %}
<br>
By analyzing the distribution of tokens in the analyzed subcorpora we can discern first clues as to differences in reviews of different genres. Firstly, Romance and Fantasy seem to include longer reviews than the other genres, with Fantasy having the greatest range of review-length and Mystery the smallest.
{% include tokeninfo_genre.html %}
## Distribution of Annotations
As can be seen here, there is a maximum of five reviews per book and the number of annotations varies widely between them.
<p align="center">
<img style="padding:0;margin:0;border:0" src="{{ "/assets\img\plots\reviews_per_title.png" | relative_url}}" width="49%"/><img style="padding:0;margin:0;border:0" src="{{ "/assets\img\plots\Annotations_per_title.png" | relative_url}}" width="49%"/>
</p>
# Preliminary Analysis
This figure shows the frequency distribution of the SWAS-dimensions in the analyzed genres. Impact seems to encompass the highest frequency of annotations (at least 30% in every genre), while Mental Imagery and Transportation seem to be phenomena that are encountered more seldomly. Furthermore, the Romance genre has distinctively more annotations in the dimension of Emotional Engagement than any other genre and fewer annotations in the dimension of Attention. Another genre with a very distinct pattern in the Absorption-dimensions is Science Fiction with almost half of its annotations belonging to the Impact dimension, which is more than any of the other genres. This is followed by the Attention dimension with almost 3o% of annotations and a lower score for the rest of the dimensions, compared to the other genres (particularly for Emotional Engagement and Mental Imagery).

![Annotation Dimensions per Genre]({{ "/assets/img/plots/dimensions_per_genre.png" | relative_url}})

Horror/Thriller and Mystery seem to follow a similar pattern. This might be due to overlaps in second or third genre, as well as being thematically closer to each other than the other genres as they both might include themes like following an investigation or crimes. This could trigger similar Absorption-responses in readers. They score notably high in the Attention-dimension and low in Emotional Engagement. Thereby, Horror/Thriller scores slightly higher in Attention, Mental Imagery – where it is marginally more frequent than the rest of the genres – and Transportation, while Mystery is more prevalent in Emotional Engagement and Impact. Fantasy scores relatively high in Impact and Emotional Engagement: it has the highest frequency of Transportation annotations and a comparably low frequency in Attention.
It should be noted that the data shown here encompasses all annotations for the respective dimensions including those tagged as Mention or Absent. This is justified by those instances being only a small fraction of the Annotations and by the assumption that recognizing a lack of a certain experience hints at the importance of said experience to the genre. Furthermore, one should keep in mind that the frequencies shown here are derived from data of varying quantity, such as the number of Fantasy annotations being threefold the number of Science Fiction annotations.
<br>The distribution of subcategories can be seen in the following graph. The visualization can be filtered by clicking on one or more genres in the graph legend. <br>To see a bigger version, the graph can be opened in a new <a href="https://tinate.github.io/jubilant-octo-doodle/tags_per_genre.html" target="_blank" rel="noopener noreferrer">tab</a>.
<iframe src="https://tinate.github.io/jubilant-octo-doodle/tags_per_genre.html" height="600" width="100%"></iframe>
