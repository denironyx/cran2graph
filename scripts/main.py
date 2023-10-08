import importlib.util

module_name = "neo4j"

spec = importlib.util.find_spec(module_name)

if spec:
    print(f'The {module_name} module is installed')
else:
    print(f'The {module_name} module is NOT installed')