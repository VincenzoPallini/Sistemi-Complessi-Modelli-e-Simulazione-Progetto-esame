### **Project: Emergency Evacuation Simulation (Implementation based on Yuan & Tan, 2007)**

**(Course: Complex Systems: Models and Simulation - Master's Degree in Computer Science, A.Y. 2022-2023)**

**General Description:**

This project addresses the critical problem of evacuating people from enclosed areas during emergency situations. The main objective was to **implement, simulate, and extend the Cellular Automata-based evacuation model proposed in the paper "An evacuation model using cellular automata" by Weifeng Yuan and Kang Hai Tan (Physica A, 2007)**. Through simulation, crowd movement dynamics were analyzed to identify environmental configurations (exit locations, presence and placement of obstacles) that optimize evacuation time and efficiency, thereby enhancing safety.

The project is based on a **microscopic modeling** approach using two-dimensional **Cellular Automata (CA)**, following the methodology of the reference paper. Each individual (agent) is simulated individually on a discrete grid representing the environment (a rectangular room).

* **Sistemi_Complessi__Modelli_e_Simulazione.pdf:** The detailed project report illustrating the methodology, simulations, results, and analysis. (**Note:** This report file is in Italian).

**Methodology and Model (Based on Yuan & Tan, 2007):**

* **Environment:** A rectangular room (main dimensions 20x16 meters, discretized into a 50x40 grid) with one or two exits and potential obstacles (columns).
* **Agents (Pedestrians):** Each agent occupies one cell and moves within its Moore neighborhood. Movement is **probabilistic**, as defined in the original model.
* **Movement Decision:** Agents choose which exit to head towards by calculating a probability (`P_i`) for each exit. This probability considers:
    * The Euclidean **distance** from the agent to the exit (`P_i-r`).
    * The **occupancy density** (number of people) in the area near the exit (`P_i-d`).
* **Behavioral Extensions:** Beyond the base model, behavioral factors were incorporated to increase realism:
    * **"Unadventurous effect":** Tendency to prefer a known exit.
    * **"Inertial effect":** Tendency not to change direction once an exit is chosen.
    * **"Field of view":** Basic ability to perceive and bypass static obstacles.
* **Tested Scenarios:** Systematic simulations were conducted (10 runs per scenario with 250 agents), varying:
    * **Number of Exits:** 1 (Base Model) and 2 (Extended Model).
    * **Exit Positions:** Central vs. Corner/Near-corner.
    * **Presence of Obstacles:** Absent vs. Present (based on additional studies).

**Technologies Used:**

* **Simulation Platform:** **NetLogo** (widely used for simulating complex systems and agent-based modeling).
* **Modeling Paradigm:** **Agent-Based Modeling (ABM)**, specifically implemented via **Cellular Automata (CA)**.
* **Analysis:** Calculation of metrics such as Total Evacuation Time (TET) and flow visualization using **Heatmaps**.

**Obtained Results:**

The simulations allowed for the validation of the model implementation and the analysis of the environmental configuration's impact on evacuation efficiency:

1.  **Exit Positions:**
    * In the absence of obstacles, **centrally** located exits tend to yield shorter evacuation times.
    * In the presence of obstacles, exits located **near corners** proved more efficient.
2.  **Impact of Obstacles:**
    * Obstacles placed in front of central exits **increased** evacuation times.
    * Strategically placed obstacles near **corner exits** **reduced** evacuation times, mitigating the bottleneck effect.
    * The **distance** of the obstacle from the exit was found to be critical.
3.  **Visualization:** The generated heatmaps clearly visualized flows, congestion points, and the effect of obstacles in directing agent movement.
4.  **Emergent Phenomena:** The model reproduced collective behaviors such as queue formation and, in the extended model, agents changing their target exit based on perceived crowding, affecting overall times.


---
