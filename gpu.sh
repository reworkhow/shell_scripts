

#set which gpu to be used
export CUDA_VISIBLE_DEVICES=0
export CUDA_VISIBLE_DEVICES=1
export CUDA_VISIBLE_DEVICES=0,1

#check the status of gpu
gpustat

#get information about cuda
cudacheck
