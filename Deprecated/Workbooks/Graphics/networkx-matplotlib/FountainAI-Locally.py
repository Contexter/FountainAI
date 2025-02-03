import matplotlib.pyplot as plt
import networkx as nx
import numpy as np

# Create the directed graph
G = nx.DiGraph()

# Define elements of the local FountainAI setup
elements = [
    "Docker Compose", "Character Service", "Central Sequence Service", 
    "Action Service", "Story Factory API", "Spoken Word Service", 
    "Session and Context Management API", "Performer Service", "Paraphrase Service",
    "FastAPI Client", "OpenAI Assistant SDK"
]

# Define the central GPT model node
gpt_model = "GPT Model"

# Add elements and the GPT model to the graph
G.add_node(gpt_model)
for element in elements:
    G.add_node(element)

# Define edges to illustrate the interactions in the local setup
edges = [
    (gpt_model, "OpenAI Assistant SDK"), 
    ("OpenAI Assistant SDK", "FastAPI Client"),
    ("FastAPI Client", "Docker Compose"),
    ("Docker Compose", "Character Service"),
    ("Docker Compose", "Central Sequence Service"),
    ("Docker Compose", "Action Service"),
    ("Docker Compose", "Story Factory API"),
    ("Docker Compose", "Spoken Word Service"),
    ("Docker Compose", "Session and Context Management API"),
    ("Docker Compose", "Performer Service"),
    ("Docker Compose", "Paraphrase Service")
]

# Add edges to the graph
G.add_edges_from(edges)

# Define positions for two concentric circles with Docker Compose at 6 o'clock
pos = {}
radius_inner = 0.5 * 1.2  # Increase radius by 20% to zoom out
radius_outer = 1.0 * 1.2  # Increase radius by 20% to zoom out

# Rotate the layout by changing the starting angle
rotation_offset = -np.pi / 2  # To place Docker Compose at 6 o'clock

# Positions for inner circle
inner_circle = [gpt_model, "OpenAI Assistant SDK", "FastAPI Client"]
theta_inner = np.linspace(0, 2 * np.pi, len(inner_circle), endpoint=False) + rotation_offset
for i, node in enumerate(inner_circle):
    pos[node] = [radius_inner * np.cos(theta_inner[i]), radius_inner * np.sin(theta_inner[i])]

# Positions for outer circle
outer_circle = [
    "Docker Compose", "Character Service", "Central Sequence Service", 
    "Action Service", "Story Factory API", "Spoken Word Service", 
    "Session and Context Management API", "Performer Service", "Paraphrase Service"
]
theta_outer = np.linspace(0, 2 * np.pi, len(outer_circle), endpoint=False) + rotation_offset
for i, node in enumerate(outer_circle):
    pos[node] = [radius_outer * np.cos(theta_outer[i]), radius_outer * np.sin(theta_outer[i])]

# Adjust label positions to move them closer to the layout center by 10%
label_pos = {node: (0.9 * x, 0.9 * y) for node, (x, y) in pos.items()}

# Draw the graph
plt.figure(figsize=(12, 12))

# Define node colors for differentiation
node_colors = [
    "lightcoral" if node in ["GPT Model", "OpenAI Assistant SDK", "FastAPI Client"] else "lightblue"
    for node in G.nodes()
]

# Draw nodes and labels
nx.draw_networkx_nodes(G, pos, node_color=node_colors, node_size=3000)
nx.draw_networkx_labels(G, label_pos, font_size=9, font_weight="bold")

# Draw edges with bows (curved lines)
for edge in edges:
    # Flip the bow direction to right open or left open for the specific edge
    if edge == ("Docker Compose", "Spoken Word Service"):
        nx.draw_networkx_edges(G, pos, edgelist=[edge], edge_color="black", connectionstyle="arc3,rad=0.3")
    elif edge in [
        ("Docker Compose", "Character Service"),
        ("Docker Compose", "Central Sequence Service"),
        ("Docker Compose", "Action Service"),
        ("Docker Compose", "Story Factory API")
    ]:
        nx.draw_networkx_edges(G, pos, edgelist=[edge], edge_color="black", connectionstyle="arc3,rad=-0.3")
    else:
        nx.draw_networkx_edges(G, pos, edgelist=[edge], edge_color="black", connectionstyle="arc3,rad=0.3")

# Remove gridlines and display the final result without title
plt.axis('off')
plt.show()

