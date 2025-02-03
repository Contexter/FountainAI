import matplotlib.pyplot as plt
import networkx as nx

# Create the directed graph
G = nx.MultiDiGraph()

# Define nodes for therapeutic tools and narrative therapy concepts
therapeutic_tools = [
    "Story Creation & Exploration", "Character Development", "Sequencing Life Events", 
    "Behavior & Action Analysis", "Dialogue & Role-Playing", "Reframing Life Events", 
    "Session & Context Tracking", "Character Role Exploration", "Paraphrasing & Reinterpretation"
]
narrative_therapy = "Re-authoring Life Story"

# Add narrative therapy model and therapeutic tools to the graph
G.add_node(narrative_therapy)
for tool in therapeutic_tools:
    G.add_node(tool)

# Define bi-directional edges for the collaborative therapeutic process
edges = [
    (narrative_therapy, "Story Creation & Exploration"), ("Story Creation & Exploration", narrative_therapy),
    (narrative_therapy, "Character Development"), ("Character Development", narrative_therapy),
    (narrative_therapy, "Sequencing Life Events"), ("Sequencing Life Events", narrative_therapy),
    (narrative_therapy, "Behavior & Action Analysis"), ("Behavior & Action Analysis", narrative_therapy),
    (narrative_therapy, "Dialogue & Role-Playing"), ("Dialogue & Role-Playing", narrative_therapy),
    (narrative_therapy, "Reframing Life Events"), ("Reframing Life Events", narrative_therapy),
    (narrative_therapy, "Session & Context Tracking"), ("Session & Context Tracking", narrative_therapy),
    (narrative_therapy, "Character Role Exploration"), ("Character Role Exploration", narrative_therapy),
    (narrative_therapy, "Paraphrasing & Reinterpretation"), ("Paraphrasing & Reinterpretation", narrative_therapy)
]

# Define positions for nodes in a symmetrical layout
pos = {
    narrative_therapy: [0, -1],  # Central concept of narrative therapy at the bottom center
    "Story Creation & Exploration": [-0.7, -0.7],
    "Character Development": [-1, 0],
    "Sequencing Life Events": [-0.7, 0.7],
    "Behavior & Action Analysis": [0, 1],
    "Dialogue & Role-Playing": [0.7, 0.7],
    "Reframing Life Events": [1, 0],
    "Session & Context Tracking": [0.7, -0.7],
    "Character Role Exploration": [0.35, -0.35],
    "Paraphrasing & Reinterpretation": [-0.35, -0.35],
}

# Create a figure with custom size
plt.figure(figsize=(26, 26))

# Set the narrative therapy node to red, and other nodes to light blue for contrast
node_colors = ["lightcoral" if node == narrative_therapy else "lightblue" for node in G.nodes()]
nx.draw_networkx_nodes(G, pos, node_color=node_colors, node_size=4000)

# Draw the labels
nx.draw_networkx_labels(G, pos, font_size=10, font_weight="normal", verticalalignment="center", horizontalalignment="center")

# Draw edges with curved lines for aesthetics
for edge in edges:
    nx.draw_networkx_edges(G, pos, edgelist=[edge], edge_color="black", connectionstyle="arc3,rad=0.5")

# Remove axis lines and grid
plt.axis('off')

# Display the graph
plt.show()

