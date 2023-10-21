import logging
import neo4j


def get_neo4j_connection(address: str="neo4j") -> neo4j.Session:
    """
    Gets a session to neo4j
    """
    driver = neo4j.GraphDatabase.driver(
        f"bolt:{address}//:7687", auth=("admin", "cran2graph")
    )
    try:
        driver.verify_connectivity()
        session = driver.session(database="neo4j")
        return session
    except Exception as connection_error:
        logging.error("Failed to establish session to neo4j", connection_error)
        session.close()
        driver.close()
        
def clean_database():
    """
    Delete all nodes and edges in Neo4j test container.
    """
    with GraphDatabase.driver(
            DEFAULT_NEO4J_URL,
            auth=(DEFAULT_NEO4J_USERNAME, DEFAULT_NEO4J_PASSWORD)
    ) as http_driver:
        q = "MATCH (n) DETACH DELETE (n)"
        try:
            session = http_driver.session()
            session.run(q)
        except Exception as e:
            print(e)
        
def test_neo4j_connection():
    driver = neo4j.GraphDatabase.driver(settings.get("NEO4J_URL"))
    with driver.session() as session:
        session.run("CALL db.indexes();")
        
def neo4j_session():
    driver = neo4j.GraphDatabase.driver(settings.get("NEO4J_URL"))
    with driver.session() as session:
        yield session
        session.run("MATCH (n) DETACH DELETE n;")
        
def init_graph():
    """Create graph db constraints."""
    driver = GraphDatabase.driver(
        cfg.neo4j_uri,
        auth=(cfg.neo4j_user, cfg.neo4j_password))
    with driver.session() as session:
        session.write_transaction(lambda tx: tx.run(
            "CREATE CONSTRAINT IF NOT EXISTS ON (p:Profile) "
            "ASSERT p.id IS UNIQUE"))
        session.write_transaction(lambda tx: tx.run(
            "CREATE CONSTRAINT IF NOT EXISTS ON (p:Profile) "
            "ASSERT p.username IS UNIQUE"))
        
 
def connect_to_neo4j(neo4j_url, neo4j_user, neo4j_pass, neo4j_encrypt):
    try:
        driver = GraphDatabase.driver(neo4j_url, auth=(neo4j_user, neo4j_pass), encrypted=neo4j_encrypt)
        with driver.session() as session:
            session.run('Match () Return 1 Limit 1')
    except ServiceUnavailable:
        logger.error('Can\'t connect to Neo4j server')
    except AuthError:
        logger.error('Neo4j authentication failed')
    else:
        return driver