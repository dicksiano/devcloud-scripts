import os
import time
import itertools

### INTEL DEV CLOUD PARAMETERS ###
AGENTS_PER_NODE = [150]
SEED = [1]

### AGENT PARAMETERS ###
MAX_VS = [1.0]
RADIUS =  [2.0, 1.5]
REWARD_RADIUS = [2.0]
COOLDOWN_TIME =  [50]
REWARD_FACTORS = [1, 0.001]
COLLISION_VELS = [2.1]
KP = [15]
BARRIER = [ [0, 0, 0] ]
DERIVATIVE_OBS = [0]
EVALUATE_BASELINE = [0]
NUM_STEP_SAME_INPUT = [1]

### NEURAL NET PARAMETERS ###
SCHEDULES = ['constant', 'linear']
HID_SIZE = [8, 64]
NUM_HIDDEN_LAYERS = [2]
EXPL_RATE = [-7]

### PPO PARAMETERS ###
MAXI_TIMESTEPS = [10000000]
TIMESTEPS_AB = [4096]
CLIP_PARAM = [ 0.1]
ENT_COEFF = [0.01]
EPOCHS = [ 10 ]
LR = [1e-5, 1e-7]
BATCH_SIZE = [1024]
GAMMA = [0.9997, 0.99]
LAMBD = [0.95, 0.999]

### Dispatch  workers ###
count = 0
search_space = itertools.product(AGENTS_PER_NODE,
                    MAX_VS, RADIUS, REWARD_RADIUS, COOLDOWN_TIME, REWARD_FACTORS, COLLISION_VELS, KP, BARRIER, DERIVATIVE_OBS, EVALUATE_BASELINE, NUM_STEP_SAME_INPUT,
                    SCHEDULES, HID_SIZE, NUM_HIDDEN_LAYERS, EXPL_RATE,
                    MAXI_TIMESTEPS, TIMESTEPS_AB, CLIP_PARAM, ENT_COEFF, EPOCHS, LR, BATCH_SIZE, GAMMA, LAMBD)


for (a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, x, y, z) in search_space:
    for replica in range(1):
        strings = ["qsub -F \"" , 
                    str(count),
                    str(a), 
                    str(b), 
                    str(c), 
                    str(d), 
                    str(e), 
                    str(f), 
                    str(g), 
                    str(h), 
                    str( i[0] ), 
                    str( i[1] ), 
                    str( i[2] ), 
                    str(j), 
                    str(k), 
                    str(l), 
                    str(m), 
                    str(n), 
                    str(o), 
                    str(p), 
                    str(q), 
                    str(r), 
                    str(s), 
                    str(t), 
                    str(u), 
                    str(v), 
                    str(x), 
                    str(y), 
                    str(z), "\" multi_searchers.sh" ]

        command = ' '.join(strings)
      
        print(command)
        os.system(command)

        count = count + 1
        time.sleep(1)
