from neo4j import GraphDatabase

class Neo4jConnect:
    def __init__(self, user, password):
        self.driver = GraphDatabase.driver("bolt://localhost:7689", auth=(user, password))
        self.user = user
    def close(self):
        self.driver.close()
        
    def query(self, db, query):
        session = self.driver.session(database=db)
        result = session.run(query)
        return result
    
    def clean_database(self):
        """
        Delete all nodes and edge in Neo4j test container
        """
        q = "MATCH (n) DETACH DELETE (n)"
        try:
            session = self.driver.session()
            session.run(q)
        except Exception as e:
            print(e)
    
    def test_neo4j_connection(self):
        """Test neo4j connection
        """
        session = self.driver.session()
        result = session.run("Match () Return 1 Limit 1")
        return result
    def __str__(self):
        return f'Connection successful for user: {self.user}.\nConnected to Neo4J database uri: {self.uri}'


import logging
import neo4j


def get_neo4j_connection(db) -> neo4j.Session:
    """
    Gets a session to neo4j
    """
    driver = neo4j.GraphDatabase.driver(
        "bolt://localhost:7689", auth=("admin", "cran2graph")
    )
    try:
        driver.verify_connectivity()
        session = driver.session(database=db)
        return session
    except Exception as connection_error:
        logging.error("Failed to establish session to neo4j", connection_error)
        session.close()
        driver.close()    
# To do specify the specify the session