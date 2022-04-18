#! /bin/bash

# Change for multinode config
CHECKPOINT_PATH=/data/qingsong/pretrain/

NUM_WORKERS=1
NUM_GPUS_PER_WORKER=8
MP_SIZE=1

script_path=$(realpath $0)
script_dir=$(dirname $script_path)
main_dir=$(dirname $script_dir)

OPTIONS_NCCL="NCCL_DEBUG=info NCCL_IB_DISABLE=0 NCCL_NET_GDR_LEVEL=2"
HOST_FILE_PATH="hostfile"
HOST_FILE_PATH="hostfile_single"

en_data="/data/qingsong/dataset/train"
eval_data="/data/qingsong/dataset/test"


config_json="$script_dir/ds_config_ft.json"
gpt_options=" \
       --experiment-name finetune-mae-cifar10 \
       --model-parallel-size ${MP_SIZE} \
       --mode finetune \
       --train-iters 1000 \
       --resume-dataloader \
       $MODEL_ARGS \
       --train-data ${en_data} \
       --valid-data ${eval_data} \
       --distributed-backend nccl \
       --lr-decay-style cosine \
       --warmup .02 \
       --checkpoint-activations \
       --save-interval 6000 \
       --eval-interval 100 \
       --save /data/qingsong/checkpoints \
       --split 1 \
       --strict-eval \
       --eval-batch-size 8 \
       --lr 0.01 \
"



gpt_options="${gpt_options}
       --deepspeed \
       --deepspeed_config ${config_json} \
"
              

run_cmd="${OPTIONS_NCCL} deepspeed --include localhost:1,2,3,4,5,6,7,8 --master_port 16666 --hostfile ${HOST_FILE_PATH} finetune_mae_cifar10.py $@ ${gpt_options}"
echo ${run_cmd}
eval ${run_cmd}

set +x
