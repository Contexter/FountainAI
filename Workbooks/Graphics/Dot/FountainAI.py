import matplotlib.pyplot as plt
import networkx as nx

# Create the directed graph
G = nx.DiGraph()

# Define API nodes and GPT model
apis = [
    "Core Script Management API", "Character Service", "Central Sequence Service", 
    "Action Service", "Story Factory API", "Spoken Word Service", 
    "Session and Context Management API", "Performer Service", "Paraphrase Service"
]
gpt_model = "GPT Model"

# Add GPT model to the graph
G.add_node(gpt_model)

# Add API nodes around GPT Model
for api in apis:
    G.add_node(api)

# Define fully interconnected edges for holistic flow
edges = [
    (gpt_model, "Core Script Management API"), (gpt_model, "Character Service"), 
    (gpt_model, "Central Sequence Service"), (gpt_model, "Action Service"),
    (gpt_model, "Story Factory API"), (gpt_model, "Spoken Word Service"),
    (gpt_model, "Session and Context Management API"), (gpt_model, "Performer Service"),
    (gpt_model, "Paraphrase Service")
]

# Add edges to the graph
G.add_edges_from(edges)

# Define the positions for a circular layout with GPT model in the center
pos = nx.circular_layout(G)
pos[gpt_model] = [0, 0]  # Move GPT to the center

# Draw the graph with the GPT model in red and other nodes in blue
plt.figure(figsize=(10, 10))

# Draw all nodes with GPT model in red
node_colors = ["lightcoral" if node == gpt_model else "lightblue" for node in G.nodes()]
nx.draw_networkx_nodes(G, pos, node_color=node_colors, node_size=4000)

# Draw the labels with smaller font size
nx.draw_networkx_labels(G, pos, font_size=8, font_weight="normal")

# Manually ensure curved edges (bows)
for edge in edges:
    nx.draw_networkx_edges(G, pos, edgelist=[edge], edge_color="black", connectionstyle="arc3,rad=0.5")

# Remove gridlines and display the final result
plt.axis('off')
plt.show()

