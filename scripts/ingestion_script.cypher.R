LOAD CSV WITH HEADERS FROM 'file:///cran_process_data.csv' AS row

WITH row, REPLACE(row.description, '"', "'") AS fixedDescription

CREATE (p:Package:Package {
  name: row.package,
  version: row.version,
  license: COALESCE(row.license, ""),
  md5sum: COALESCE(row.md5sum, ""),
  description: COALESCE(row.fixedDescription, ""),
  published: date(row.published_date)
})

MERGE (a:Person:Person {
  name: COALESCE(row.author, "N/A"),
  email: COALESCE(row.email, "N/A") // Replace null with "N/A" or your preferred default value
})

MERGE (a)-[:CONTRIBUTED_TO]->(p)
MERGE (a)-[:MAINTAINS]->(p)

MERGE (p)-[:DEPENDS_ON]->(d:Package:Dependency {
  name: COALESCE(row.depends, "")
})

MERGE (p)-[:DEPENDS_ON]->(i:Package:Dependency {
  name: COALESCE(row.imports, "")
})

MERGE (p)-[:LICENSED_BY]->(:License:License {
  name: COALESCE(row.license, "")
})

MERGE (a)-[:WORKS_AT]->(:Company:Company {
  work: COALESCE(row.institution, ""),
  category: COALESCE(row.domain, "")
})


------------------


LOAD CSV WITH HEADERS FROM 'file:///cran_process_data.csv' AS row

WITH row, REPLACE(row.description, '"', "'") AS fixedDescription

CREATE (p:Package:Package {
    name: row.package,
    version: row.version,
    license: COALESCE(row.license, ""),
    md5sum: COALESCE(row.md5sum, ""),
    description: COALESCE(row.fixedDescription, ""),
    published: date(row.published_date)
})

MERGE (a:Person:Person {
    name: COALESCE(row.author, "N/A"),
    email: COALESCE(row.email, "N/A") // Replace null with "N/A" or your preferred default value
})

MERGE (a)-[:CONTRIBUTED_TO]->(p)
MERGE (a)-[:MAINTAINS]->(p)

MERGE (p)-[:DEPENDS_ON]->(d:Package:Dependency {
    name: COALESCE(row.depends, "")
})

MERGE (p)-[:DEPENDS_ON]->(i:Package:Dependency {
    name: COALESCE(row.imports, "")
})

MERGE (p)-[:LICENSED_BY]->(:License:License {
    name: COALESCE(row.license, "")
})

MERGE (a)-[:WORKS_AT]->(:Company:Company {
    work: COALESCE(row.institution, ""),
    category: COALESCE(row.domain, "")
})
