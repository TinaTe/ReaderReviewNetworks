---
layout: page
title : Cluster Analysis
permalink: /cluster/
feature-img: "assets/img/header/darknet.png"
---

* TOC
{:toc}

# Isolated Cluster Network

If one isolates the clusters that were chosen for this analysis, the network reveals a very interesting structure. It seems like the clusters predominantly consisting of Horror/Thriller, Science Fiction and Mystery (01, 04, 07 and 08) are more interconnected than the Romance clusters (12 and 11). Furthermore, the size of the nodes was modified to show degree centrality, which indicates how many nodes they are directly connected to. This gives an impression of their influence inside the clusters. We can see, for example, that the Mystery-nodes in cluster 04 seem to have more direct connections than the nodes of other genres in the cluster, as is also observable for clusters 07 and 11 and their corresponing dominant genre.

![Isolated Clusters]({{ "/assets/img/plots/isolated_clusters.png" | relative_url}})

# Cluster Analysis

While a network in itself provides a wealth of information, to correctly interpret what is seen in the presented structure, an in-depth analysis is needed. The main hypothesis of this study is that the network will reveal meaningful structures within the dataset. To uncover these structures, several methods are applied.
First, the newly revealed information of community-membership is extracted from the network data and added to the original dataset. After that, general descriptive statistics about genre-dispersion are calculated to put the result into perspective. Furthermore, the analysis of absorption patterns as described in the preliminary analysis is repeated in the context of the clustering. The next step is to recalculate text similarity for the reviews adding the document variable of community membership. This allows for the application of corpus related methods that will then be used as guidance for a close reading analysis. The methods applied are keyness analysis and concordance analysis.

<p align="center">
<img style="padding:0;margin:0;border:0" src="{{ "/assets\img\plots\categories_per_cluster.png" | relative_url}}" width="49%"/><img style="padding:0;margin:0;border:0" src="{{ "/assets\img\plots\dimensions_per_genre.png" | relative_url}}" width="49%"/>
</p>

The above graph on the left showcases that all clusters have rather distinct absorption patterns and words frequently appearing in the reviews overlap with those often used in absorption statements. These patterns can be compared with the distributions in the overall genre on the right. While most of them align with what would be expected by the genre that is best represented in the respective cluster, there are few exceptions. One is cluster 01, with an emphasis on characters and encompassing all Science Fiction reviews that contain Emotional Engagement. Another exception is cluster 12, which scores noticeably low on emotional engagement, although it mostly contains Romance reviews. This points to a subclass of Romance reviews which, even though focusing on characters, does not show the same emphasis on emotional connection with them as opposed to readers in cluster 11.

<br>To see a bigger version, the graph can be opened in a new <a href="https://tinate.github.io/jubilant-octo-doodle/tags_per_cluster.html" target="_blank" rel="noopener noreferrer">tab</a>.
<iframe src="https://tinate.github.io/jubilant-octo-doodle/tags_per_cluster.html" height="600" width="100%"></iframe>


# Individual Cluster Analysis

A more detailed discussion of the individual clusters can be accessed by clicking on the images below.

{% include portfolio.html %}
