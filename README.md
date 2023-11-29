# Enhancing Package Recommendation in CRAN Open Source Ecosystem with "Cran2Graph"

## Context:

The open source ecosystem, particularly Comprehensive R Archive Network (CRAN) has grown substantially, making it challenging for users to identify relevant R packages and understand the relationships between authors, package, and maintainers. Traditional recommendation systems are limited in their ability to provide such detailed information. "Cran2Graph" proposes to address this issue by leveraging knowledge graphs and large language models.

## Research gap

R users face a daunting challenge in discovering relevant CRAN packages and relationships due to the vast and diverse nature of the ecosystem. Existing recommendations systems often rely on simplistic methods, such as keyword matching and basic metadata analysis, which fails to capture the semantic intricacies of package functionalities and dependencies.

## Objectives:

- To design and develop Cran2Graph, a system that leverages knowledge graphs and large language models to enhance open-source package. 
- To evaluate the effectiveness of Cran2Graph in answering user questions about the authors relationships with packages, package maintainers. 
- To establish comprehensive evaluation metrics for assessing the quality of package recommendations.

## Methodological approach:

![Methodology](./img/methodology_cran.png)

The research will involve the design and development of the "Cran2Graph" recommendation system, integrating neo4j for knowledge graph representation and large language models for semenatic understanding.

## Expected results:

The expected results include the successful implementation of the Cran2Graph system, providing users with context-aware and semantically enriched package recommendations. Additionally, the system is expected to effectively answer user questions about authors relationship with packages.

## Contributions:

This research project contributes to the enhancement of open source package recommendation in the Cran ecosystem by introducing "Cran2Graph", a recommendation system. It provides a methodology for integrating knowledge graphs and large language models into recommendation systems, with implications beyond the R ecosystem. The methodology used would improve answering detailed questions about open source package relationships.

#### References
- https://towardsdatascience.com/integrate-llm-workflows-with-knowledge-graph-using-neo4j-and-apoc-27ef7e9900a2


### Testing Graph

MATCH (a:Person {name: 'Jing Zhang'})-[:MAINTAINS]->(p:Package)
RETURN a,p
LIMIT 10;

----

MATCH (a:Person {name: 'Hadley Wickham'})-[:CONTRIBUTED_TO]->(p:Package)
RETURN p;


----- working

MATCH (a:Person {name: 'Jing Zhang'})-[:MAINTAINS]->(maintainedPackage)
MATCH (a)-[:CONTRIBUTED_TO]->(contributedPackage)
RETURN a, maintainedPackage, contributedPackage


-----
MATCH (a:Person {name: 'Jing Zhang'})-[:CONTRIBUTED_TO]->(p:Package)
MATCH (p)-[:LICENSE_BY]->(l:License)
MATCH (a)-[:WORKS_IN]->(i:Institution)
RETURN a,p, l, i
LIMIT 10;

-----
MATCH(d:Dependency {name: "dplyr"}) <-[:DEPENDS_ON]-(p:Package)
RETURN d, p 
LIMIT 25;

-----
MATCH (p:Package {name: "dplyr"}) -[:DEPENDS_ON]->(d:Package)

RETURN p, d
limit 25;

---

MATCH (a:Person {name: 'Kirill Müller'})-[:CONTRIBUTED_TO]-(p:Package)
RETURN p, a

MATCH (a:Person {name: 'Jing Zhang'})-[:CONTRIBUTED_TO]->(p:Package)
MATCH (p)-[:LICENSE_BY]->(l:License)
MATCH (p)-[:DEPENDS_ON]->(d:Package)
MATCH (a)-[:WORKS_IN]->(i:Institution)
RETURN a,p, l, i, d
LIMIT 25;


-----

MATCH (a:Person {name: 'Kirill Müller'})-[:CONTRIBUTED_TO]->(p:Package)
WHERE NOT (a)-[:DEPENDS_ON]->(p) AND NOT (a)-[:MAINTAINS]->(p)
RETURN a, p

-------
MATCH (p:Person {name: 'Kirill Müller'})-[:MAINTAINS]->(pkg:Package)
RETURN pkg.name


------ dependency count
MATCH (p1:Package)-[:DEPENDS_ON]->(p2:Package)
WITH p2, COUNT(p1) AS dependencyCount
ORDER BY dependencyCount DESC
RETURN p2, dependencyCount


# TO do

- query a email string to find 'edu', or 'math'
- Having issue creating index for person, and package nodes.

Required to isntall `nmslib`

License <https://opensource.org/licenses/>

Experiencing difficult split the domain, institution from the maintainer column why [erch\@mathematik.uni-marburg.de](mailto:erch@mathematik.uni-marburg.de){.email} mathematik Florian [Lerchlerch\@mathematik.uni-marburg.de](mailto:Lerchlerch@mathematik.uni-marburg.de){.email}\>



- Learn more about MERGE clause and it's tricks.
- MERGE is a match command with  a convention with a create command. WHen it matches with the node and properties, it first try to matches and then if it doesn't find it creates a new node. 
- I don't want to merge on author. So, I need to think about what happen when there is MATCH is found. 
- Create all of the node for author seperate csv, create what we have for package separate csv. 
- Heuristic approach -  give me all the name of the people who the names are the same, contributes to the same package and they have different email. Add a relationship to them as "same_as" 
- Look into a graph projection native projection 
- ETL 


### References
- https://towardsdatascience.com/integrate-llm-workflows-with-knowledge-graph-using-neo4j-and-apoc-27ef7e9900a2


Note: CRAN DATA, like any other dataset, has its limitations and potential biases. Some data may not be collected or reported uniformly across different regions or time periods, which can affect the comparability of results. Users should keep these limitations in mind when interpreting the results of their queries and exercise caution when making decisions based on census data.


--- SOurce: https://crandb.r-pkg.org:2053/cran/_design/internal/_view/new 


557 was removed when I remove rows that contains Rstudio or RStudio


## The database retain it's encoding from western europe characters and utf-8

Kirill Müller
Kirill Müller


## To do
- rgdal dependencies isn't showing
- Develop a use case to exploring the dependency in the geospatial community
