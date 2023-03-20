### rife v4 倍帧（强制输出8比特），性能要求很高

import vapoursynth as vs
from vapoursynth import core
import math

input = video_in
colorlv = input.get_frame(0).props._ColorRange
fmt_src = input.format

############
# 用户选项 #
############

Max_Leng = 720
Sc_mode = 1
GPU = 0
GPU_t = 2
Static_th = 60.0
## 若视频的短边超过该长度将被强制降采样，以画质交换性能
## <0|1|2> 场景切换检测的模式，0为禁用
## 使用的显卡序号，0为排序一号
## 使用的显卡线程数
## 静止帧的检测阈值，不对该类帧进行补偿计算

if container_fps > 32 :
	raise Exception("源帧率超过限制的范围，已临时禁用该脚本。")

if input.width >= input.height :
	short_edge = input.height
	max_Leng2 = input.width*(Max_Leng/input.height)
	w_ds = max_Leng2
	h_ds = Max_Leng
else :
	short_edge = input.width
	max_Leng2 = input.height*(Max_Leng/input.width)
	w_ds = Max_Leng
	h_ds = max_Leng2

if fmt_src.subsampling_w or fmt_src.subsampling_h :
	if not (w_ds % 2 == 0) :
		w_ds = math.floor(w_ds / 2) * 2
	if not (h_ds % 2 == 0) :
		h_ds = math.floor(h_ds / 2) * 2

if Sc_mode == 0 :
	cut0 = input
elif Sc_mode == 1 :
	cut0 = core.misc.SCDetect(clip=input, threshold=0.15)
elif Sc_mode == 2 :
	sup = core.mv.Super(clip=input, pel=1)
	vec = core.mv.Analyse(super=sup, isb=True)
	cut0 = core.mv.SCDetection(clip=input, vectors=vec, thscd1=240, thscd2=130)

if short_edge > Max_Leng :
	cut1 = core.resize.Bicubic(clip=cut0, width=w_ds, height=h_ds, format=vs.RGBS, matrix_in_s="709")
else :
	cut1 = core.resize.Bilinear(clip=cut0, format=vs.RGBS, matrix_in_s="709")
cut2 = core.rife.RIFE(clip=cut1, model=9, factor_num=2, factor_den=1, gpu_id=GPU, gpu_thread=GPU_t, sc=True if Sc_mode else False, skip=True, skip_threshold=Static_th)

output = core.resize.Bilinear(clip=cut2, format=vs.YUV420P8, matrix_s="709", range=1 if colorlv==0 else None)

output.set_output()
