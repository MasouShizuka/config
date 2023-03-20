### rife v4 补帧，性能要求非常高

import vapoursynth as vs
from vapoursynth import core

input = video_in
colorlv = input.get_frame(0).props._ColorRange
fmt_in = input.format.id

############
# 用户选项 #
############

Sc_mode = 1
FPS_num = 2
FPS_den = 1
GPU = 0
GPU_t = 2
## <0|1|2> 场景切换检测的模式，0为禁用
## FPS_num/FPS_den 的值即帧率倍数（分子分母必须为整数，计算结果可为浮点；只支持 v4 模型）
## .
## 使用的显卡序号，0为排序一号
## 使用的显卡线程数

if container_fps > 32 :
	raise Exception("源帧率超过限制的范围，已临时禁用该脚本。")

if Sc_mode == 0 :
	cut0 = input
elif Sc_mode == 1 :
	cut0 = core.misc.SCDetect(clip=input, threshold=0.15)
elif Sc_mode == 2 :
	sup = core.mv.Super(clip=input, pel=1)
	vec = core.mv.Analyse(super=sup, isb=True)
	cut0 = core.mv.SCDetection(clip=input, vectors=vec, thscd1=240, thscd2=130)

cut1 = core.resize.Bilinear(clip=cut0, format=vs.RGBS, matrix_in_s="709")
cut2 = core.rife.RIFE(clip=cut1, model=9, factor_num=FPS_num, factor_den=FPS_den, gpu_id=GPU, gpu_thread=GPU_t, sc=True if Sc_mode else False, skip=True, skip_threshold=60.0)

output = core.resize.Bilinear(clip=cut2, format=fmt_in, matrix_s="709", range=1 if colorlv==0 else None)

output.set_output()
