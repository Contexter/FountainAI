import matplotlib.pyplot as plt
import networkx as nx
import numpy as np

# Create the directed graph
G = nx.DiGraph()

# Define nodes representing different stages of the FountainAI document assembly process
nodes = [
    "Core Script Management Service", "Character Service", "Central Sequence Service", 
    "Action Service", "Spoken Word Service", "Session and Context Management Service",
    "Segmentation and Storage", "Contextual Linking", "Handling Token Limits and Errors",
    "Retrieval and Assembly", "Formatting the Final Document", "Assembled Document"
]

# Add nodes to the graph
G.add_nodes_from(nodes)

# Define edges showing how nodes contribute to document assembly
edges = [
    ("Core Script Management Service", "Segmentation and Storage"),
    ("Character Service", "Contextual Linking"),
    ("Central Sequence Service", "Contextual Linking"),
    ("Action Service", "Segmentation and Storage"),
    ("Spoken Word Service", "Segmentation and Storage"),
    ("Session and Context Management Service", "Handling Token Limits and Errors"),
    ("Segmentation and Storage", "Retrieval and Assembly"),
    ("Contextual Linking", "Retrieval and Assembly"),
    ("Handling Token Limits and Errors", "Retrieval and Assembly"),
    ("Retrieval and Assembly", "Formatting the Final Document"),
    ("Formatting the Final Document", "Assembled Document")
]

# Add edges to the graph
G.add_edges_from(edges)

# Define positions for nodes in a circular layout like the face of a clock
pos = nx.circular_layout(G)

# Rotate the layout to make the "Assembled Document" node appear at the 6 o'clock position
rotation_angle = np.pi / 2  # Rotate 90 degrees counterclockwise to bring it to the bottom
rotated_pos = {
    node: [np.cos(rotation_angle) * x - np.sin(rotation_angle) * y,
           np.sin(rotation_angle) * x + np.cos(rotation_angle) * y]
    for node, (x, y) in pos.items()
}

# Zoom out by scaling positions to prevent label cut-off
scale_factor = 5.0
scaled_pos = {node: (x * scale_factor, y * scale_factor) for node, (x, y) in rotated_pos.items()}

# Draw the graph
plt.figure(figsize=(12, 12))

# Draw nodes with different colors for input, processing, and output nodes
node_colors = []
for node in G.nodes():
    if node == "Assembled Document":
        node_colors.append("lightcoral")
    elif node in [
        "Segmentation and Storage", "Contextual Linking", "Handling Token Limits and Errors",
        "Retrieval and Assembly", "Formatting the Final Document"
    ]:
        node_colors.append("lightgreen")
    else:
        node_colors.append("lightblue")

nx.draw_networkx_nodes(G, scaled_pos, node_color=node_colors, node_size=3000)

# Align labels towards the graph center (aspect ratio center)
label_pos = {}
for node, (x, y) in scaled_pos.items():
    label_offset = 0.85  # Position labels closer towards the center
    label_pos[node] = (x * label_offset, y * label_offset)

# Draw labels with alignment towards the graph center
nx.draw_networkx_labels(G, label_pos, font_size=10, font_weight="bold", horizontalalignment='center', verticalalignment='center')

# Draw edges with arrows to indicate data flow direction
nx.draw_networkx_edges(G, scaled_pos, edgelist=edges, edge_color="black", arrows=True, arrowstyle='-|>', arrowsize=15)

# Remove axis gridlines and show the plot
plt.axis('off')
plt.show()
