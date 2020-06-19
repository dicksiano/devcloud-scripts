#!/usr/bin/env python
from mpi4py import MPI
from baselines.common import boolean_flag, set_global_seeds, tf_util as U
from baselines import bench
import os.path as osp
import gym
import logging
from baselines import logger
import sys

sys.path.insert(0, '../../..')

from core.soccer_env import SoccerEnv

INVALID = -9999

def train(env_id, 
            num_timesteps, 
            seed, 
            save_model, 
            load_model, 
            model_dir, 
            timesteps_per_actorbatch,
            clip_param, 
            ent_coeff, 
            epochs, 
            learning_rate, 
            batch_size, 
            gamma, 
            lambd, 
            exploration_rate, 
            filename,
            schedule,
            hid_siz,
            num_hid_layers):
    from baselines.ppo1 import pushrecovery_policy, kick_policy, pposgd_simple, reward_scaler
    rank = MPI.COMM_WORLD.Get_rank()
    U.make_session(num_cpu=1).__enter__()
    workerseed = seed + 10000 * rank
    set_global_seeds(workerseed)
    env = SoccerEnv(rank)

    def policy_fn(name, ob_space, ac_space):
        return pushrecovery_policy.PushRecoveryPolicy(name=name, ob_space=ob_space, ac_space=ac_space,
                                    hid_size=hid_siz, num_hid_layers=num_hid_layers, exploration_rate=exploration_rate)

    env = bench.Monitor(env, logger.get_dir())
    env.seed(workerseed)
    gym.logger.setLevel(logging.WARN)

    #rw_scaler = reward_scaler.RewardScaler("rw_scaler")
    pposgd_simple.learn(env, policy_fn, 
                        max_timesteps=num_timesteps,
                        timesteps_per_actorbatch=timesteps_per_actorbatch,
                        clip_param=clip_param, 
                        entcoeff=ent_coeff,
                        optim_epochs=epochs, 
                        optim_stepsize=learning_rate, 
                        optim_batchsize=batch_size,
                        gamma=gamma, 
                        lam=lambd, 
                        schedule=schedule,
                        save_model=save_model, 
                        load_model=load_model, 
                        model_dir=model_dir, 
                        rw_scaler=None, filename=filename
                        )
    env.close()


def main():
    import argparse
    parser = argparse.ArgumentParser(
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)

    # Default paramters
    parser.add_argument('--env', help='environment ID', default='Hopper-v1')
    parser.add_argument('--seed', help='RNG seed', type=int, default=0)
    boolean_flag(parser, 'save-model', default=True)
    boolean_flag(parser, 'load-model', default=False)
    parser.add_argument('--model-dir')

    # Agent parameters
    parser.add_argument('--max_vel', type=float, default=INVALID)
    parser.add_argument('--radius', type=float, default=INVALID)
    parser.add_argument('--reward_radius', type=float, default=INVALID)
    parser.add_argument('--cooldown_time', type=float, default=INVALID)
    parser.add_argument('--reward_factor', type=float, default=INVALID)
    parser.add_argument('--collision_vel', type=float, default=INVALID)
    parser.add_argument('--kp', type=float, default=INVALID)
    parser.add_argument('--xw', type=float, default=INVALID)
    parser.add_argument('--yw', type=float, default=INVALID)
    parser.add_argument('--zw', type=float, default=INVALID)
    parser.add_argument('--derivative', type=float, default=INVALID)
    parser.add_argument('--eval_basel', type=float, default=INVALID)
    parser.add_argument('--num_t_same_input', type=float, default=INVALID)

    # Neural net parameters
    parser.add_argument('--schedule', default="-1")
    parser.add_argument('--hid_siz', type=int, default=INVALID)
    parser.add_argument('--num_hid_layers', type=int, default=INVALID)
    parser.add_argument('--exploration_rate', type=float, default=INVALID)

    # PPO parameters
    parser.add_argument('--num_timesteps', type=int, default=INVALID)
    parser.add_argument('--timesteps_per_actorbatch', type=int, default=4096)
    parser.add_argument('--clip_param', type=float, default=0.1)
    parser.add_argument('--ent_coeff', type=float, default=0.01)
    parser.add_argument('--epochs', type=int, default=10)
    parser.add_argument('--learning_rate', type=float, default=1e-5)
    parser.add_argument('--batch_size', type=int, default=1024)
    parser.add_argument('--gamma', type=float, default=0.99)
    parser.add_argument('--lambd', type=float, default=0.95)

    # PPO parameters
    args = parser.parse_args()
    # logger.configure()

    filename =  str(args.max_vel).replace('.','*') + "_" + \
                str(args.radius).replace('.','*') + "_" + \
                str(args.reward_radius).replace('.','*') + "_" + \
                str(args.cooldown_time).replace('.','*') + "_" + \
                str(args.reward_factor).replace('.','*') + "_" + \
                str(args.collision_vel).replace('.','*') + "_" + \
                str(args.kp).replace('.','*') + "_" + \
                str(args.xw).replace('.','*') + "_" + \
                str(args.yw).replace('.','*') + "_" + \
                str(args.zw).replace('.','*') + "_" + \
                str(args.derivative).replace('.','*') + "_" + \
                str(args.eval_basel).replace('.','*') + "_" + \
                str(args.num_t_same_input).replace('.','*') + "___" + \
                str(args.schedule).replace('.','*') + "_" + \
                str(args.hid_siz).replace('.','*') + "_" + \
                str(args.num_hid_layers).replace('.','*') + "_" + \
                str(args.exploration_rate).replace('.','*') + "___" + \
                str(args.num_timesteps).replace('.','*') + "_" + \
                str(args.timesteps_per_actorbatch).replace('.','*') + "_" + \
                str(args.clip_param).replace('.','*') + "_" + \
                str(args.ent_coeff).replace('.','*') + "_" + \
                str(args.epochs).replace('.','*') + "_" + \
                str(args.learning_rate).replace('.','*') + "_" + \
                str(args.batch_size).replace('.','*') + "_" + \
                str(args.gamma).replace('.','*') + "_" + \
                str(args.lambd).replace('.','*')
    
    print(filename)
    #logger.set_dir(logger.get_dir()+'___'+filename)

    if args.load_model and args.model_dir is None:
        print("When loading model, you should set --model-dir")
        return

    train(args.env, 
            num_timesteps=args.num_timesteps, 
            seed=args.seed,
            save_model=args.save_model, 
            load_model=args.load_model, 
            model_dir=args.model_dir,
            timesteps_per_actorbatch=args.timesteps_per_actorbatch, 
            clip_param=args.clip_param,
            ent_coeff=args.ent_coeff, 
            epochs=args.epochs, 
            learning_rate=args.learning_rate,
            batch_size=args.batch_size, 
            gamma=args.gamma, 
            lambd=args.lambd, 
            exploration_rate=args.exploration_rate, 
            filename = filename,
            schedule=args.schedule,
            hid_siz=args.hid_siz, 
            num_hid_layers=args.num_hid_layers)

if __name__ == '__main__':
    main()

